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
    @IBOutlet var edit: UIBarButtonItem!

    var device: DeviceListItem!
    private var timer: Timer!
    private var unwind = false
    
    var color: Color {
        get {
            return Color(h: Float(colorWheel.hue), s: Float(saturatonSlider.fraction), l: Float(luminanceSlider.fraction))
        }
        set {
            colorWheel.hue = CGFloat(newValue.h)
            saturatonSlider.fraction = CGFloat(newValue.s)
            luminanceSlider.fraction = CGFloat(newValue.l)
            updateColors()
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.colorWheel.delegate = self
        self.saturatonSlider.delegate = self
        self.luminanceSlider.delegate = self
        
        self.color = self.device.color!
        self.title = self.device.name!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if unwind {
            self.performSegue(withIdentifier: "unwindToDevices", sender: self)
        } else {
            self.device.client.connectionDelegate += self
            self.device.client.communicationDelegate += self
            if (!self.device.client.isConnected) {
                showDisconnected()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        colorWheel.spotColor = color.toCGColor()
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
        _ = device.client.updateColor(color)
    }
            
    func websocketDidConnect(client: WebSocketClient) {
        self.presentedViewController?.performSegue(withIdentifier: "unwindToDetails", sender: self)
        self.edit.isEnabled = true
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        showDisconnected()
    }
    
    func showDisconnected() {
        self.performSegue(withIdentifier: "disconnected", sender:self)
        self.edit.isEnabled = false
    }
    
    func setColorAnimated(color: Color) {
        self.colorWheel.setHueAnimated(CGFloat(color.h))
        self.saturatonSlider.setFracAnimated(CGFloat(color.s))
        self.luminanceSlider.setFracAnimated(CGFloat(color.l))
        updateColors()
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
        if (newColor != color) {
            setColorAnimated(color: newColor)
        }
    }
    
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings) {
        self.title = settings.deviceName
    }
    
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings) {
        self.title = settings.deviceName
    }
    
    @IBAction func unwindToDetails(_ segue:UIStoryboardSegue) {
        print("unwind to details")
        unwind = true
    }
    
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
