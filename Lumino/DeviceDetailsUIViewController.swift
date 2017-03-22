//
//  DeviceDetailsUIView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit
import Starscream

class DeviceDetailsUIViewController: UIViewController, WebSocketDelegate, ColorWheelDelegate, GradientSiliderDelegate {

    @IBOutlet weak var textView: UITextView!
    var text = String()
    var socket: WebSocket!
    // IBOutlet for the ColorPicker
    @IBOutlet var colorWheel: ColorWheel!
    @IBOutlet var colorSpot: ColorSpotView!
    @IBOutlet var saturatonSlider: GradientSilider!
    @IBOutlet var luminanceSlider: GradientSilider!
    
    var color: UIColor {
        get {
            return UIColor(hue: colorWheel.hue, saturation: saturatonSlider.fraction, brightness: luminanceSlider.fraction, alpha: CGFloat(1))
        }
        set {
            var h: CGFloat = 0
            var s: CGFloat = 0
            var l: CGFloat = 0
            var a: CGFloat = 0
            
            newValue.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
            colorWheel.hue = h
            saturatonSlider.fraction = s
            luminanceSlider.fraction = l
            updateColors()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device"
       // textView.text = text
        socket = WebSocket(url: URL(string: "ws://192.168.1.76/ws")!)
        socket.delegate = self
        socket.connect()
        color = UIColor.red
        colorWheel.delegate = self
        saturatonSlider.delegate = self
        luminanceSlider.delegate = self
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
        colorSpot.backgroundColor = color
        sendColor()
    }
    
    func HueChanged(_ hue: CGFloat, wheel: ColorWheel) {
        updateColors()
    }
    
    func GradientChanged(_ gradient: CGFloat, slider: GradientSilider) {
        if (slider == saturatonSlider) {
            updateLuminance()
        }
        updateColorSpot()
    }
    
    func sendColor() {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            print("R: \(r) G: \(g) B: \(b)")
            socket.write(string: "{\"_type\": \"request\", \"requestType\": \"update\", \"resource\": \"color\",\"content\": {\"_type\": \"color\", \"r\": \(Int(r * 255)), \"g\": \(Int(g * 255)), \"b\": \(Int(b * 255))}}")
        }
    }

    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("got some data: \(data.count)")
    }
    
}
