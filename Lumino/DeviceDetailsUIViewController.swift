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

    var client: WebSocketClient!
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
        self.title = "Device"
        colorWheel.delegate = self
        saturatonSlider.delegate = self
        luminanceSlider.delegate = self
        
        client.connectionDelegate += self
        client.communicationDelegate += self
        _ = client.requestColor()
        _ = client.requestSettings()
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
        _ = client.updateColor(color.toColor())
    }
    
    func websocketDidConnect(client: WebSocketClient) {
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        // Show the message and close the dialog
    }
    
    func websocketOnColorRead(client: WebSocketClient,  color: Color) {
        self.color = color.toUIColor()
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
            color = newColor.toUIColor()
        }
    }
    
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings) {
        self.title = settings.deviceName
    }
    
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings) {
    }
}
