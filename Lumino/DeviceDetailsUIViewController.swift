//
//  DeviceDetailsUIView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit

class DeviceDetailsUIViewController: UIViewController, ColorWheelDelegate, GradientSiliderDelegate, WebSocketClientDelegate {

    @IBOutlet var colorWheel: ColorWheelView!
    @IBOutlet var saturatonSlider: GradientSiliderView!
    @IBOutlet var luminanceSlider: GradientSiliderView!

    private var socket: WebSocketClient!
    var service: NetService!
    
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
        
        let serializer = SerializationService()
        serializer.addSerializer(Color.self, ColorSerializer())
        serializer.addSerializer(Settings.self, SettingsSerializer())
        serializer.addSerializer(Request.self, RequestSerializer())
        serializer.addSerializer(Response.self, ResponseSerializer())
        serializer.addSerializer(Event.self, EventSerializer())
        serializer.addSerializer(Status.self, StatusSerializer())

        socket = WebSocketClient(serializer, service)
        socket.delegate = self
        socket.connect()
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
        sendColor()
    }
    
    func HueChanged(_ hue: CGFloat, wheel: ColorWheelView) {
        updateColors()
    }
    
    func GradientChanged(_ gradient: CGFloat, slider: GradientSiliderView) {
        if (slider == saturatonSlider) {
            updateLuminance()
        }
        updateColorSpot()
    }
    
    func sendColor() {
        _ = socket.updateColor(color.toColor())
    }
    
    func websocketDidConnect() {
        _ = socket.requestColor()
        _ = socket.requestSettings()
    }
    
    func websocketDidDisconnect() {
        
    }
    
    func websocketOnColorRead(color: Color) {
        self.color = color.toUIColor()
    }

    func websocketOnColorUpdated(color: Color) {
        
    }
    
    func websocketOnSettingsRead(settings: Settings) {
        self.title = settings.deviceName
    }
    
    func websocketOnSettingsUpdated(settings: Settings) {
        
    }
}
