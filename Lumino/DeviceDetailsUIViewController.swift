//
//  DeviceDetailsUIView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit
import MulticastDelegateSwift

class DeviceDetailsUIViewController: UIViewController, ColorWheelDelegate, GradientSiliderDelegate, WebSocketConnectionDelegate, WebSocketCommunicationDelegate {

    @IBOutlet var colorWheel: ColorWheelView!
    @IBOutlet var saturatonSlider: GradientSiliderView!
    @IBOutlet var luminanceSlider: GradientSiliderView!

    var device: DeviceListItem!
    private var timer: Timer!
    
    var color: UIColor {
        get {
            return UIColor(hue: colorWheel.hue, saturation: saturatonSlider.fraction, brightness: luminanceSlider.fraction, alpha: CGFloat(1))
        }
        set {
            newValue.getHue({
                h, s, l in
                colorWheel.hue = h
                saturatonSlider.fraction = s
                luminanceSlider.fraction = l
                updateColors()
            })
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorWheel.delegate = self
        self.saturatonSlider.delegate = self
        self.luminanceSlider.delegate = self
        
        self.color = self.device.color!.toUIColor()
        self.title = self.device.name!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.device.client.connectionDelegate += self
        self.device.client.communicationDelegate += self
        if (!self.device.client.isConnected) {
            showDisconnected()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.device.client.connectionDelegate -= self
        self.device.client.communicationDelegate -= self
    }
    
    func updateColors() {
        updateSaturation()
        updateLuminance()
        updateColorSpot()
    }
    
    func updateSaturation() {
        let pureColor = UIColor(hue: colorWheel.hue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
        saturatonSlider.uicolors = [pureColor, UIColor.white]
    }
    
    func updateLuminance() {
        let saturatedColor = UIColor(hue: colorWheel.hue, saturation: saturatonSlider.fraction, brightness: CGFloat(1), alpha: CGFloat(1))
        luminanceSlider.uicolors = [saturatedColor, UIColor.black]
    }
    
    func updateColorSpot() {
        colorWheel.spotColor = color.cgColor
    }
    
    func HueChanged(_ hue: CGFloat, wheel: ColorWheelView) {
        updateColors()
        sendColor()
    }
    
    func GradientChanged(_ gradient: CGFloat, slider: GradientSiliderView) {
        if (slider == saturatonSlider) {
            updateLuminance()
        }
        updateColorSpot()
        sendColor()
    }
    
    func sendColor() {
        _ = device.client.updateColor(color.toColor())
    }
            
    func websocketDidConnect(client: WebSocketClient) {
        if self.navigationController?.presentedViewController != self {
            self.presentedViewController?.performSegue(withIdentifier: "connected", sender: self)
        }
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        showDisconnected()
    }
    
    func showDisconnected() {
        self.performSegue(withIdentifier: "disconnected", sender:self)
    }
    
    func setColorAnimated(color: Color) {
        let uiColor = color.toUIColor()
        uiColor.getHue({
            h, s, l in
            self.colorWheel.setHueAnimated(h)
            self.saturatonSlider.setFracAnimated(s)
            self.luminanceSlider.setFracAnimated(l)
            updateColors()
        })
    }
    
    func websocketOnColorRead(client: WebSocketClient,  color: Color) {
        setColorAnimated(color: color)
    }

    func websocketOnColorUpdated(client: WebSocketClient, color: Color) {
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateColor), userInfo: color, repeats: false);
    }
    
    func updateColor() {
        let newColor: Color = timer.userInfo as! Color
        if (newColor != color.toColor()) {
            setColorAnimated(color: newColor)
        }
    }
    
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings) {
        self.title = settings.deviceName
    }
    
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings) {
        self.title = settings.deviceName
    }
    
    @IBAction func connected(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings"{
            if let nextNavController = segue.destination as? UINavigationController {
                if let nextViewController = nextNavController.visibleViewController as? SettingsViewController {
                    nextViewController.device = device
                }
            }
        }
    }

}
