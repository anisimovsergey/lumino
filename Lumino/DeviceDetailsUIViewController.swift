//
//  DeviceDetailsUIView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit
import Starscream

class DeviceDetailsUIViewController: UIViewController, ColorWheelDelegate, GradientSiliderDelegate {

    @IBOutlet var colorWheel: ColorWheelView!
    @IBOutlet var saturatonSlider: GradientSiliderView!
    @IBOutlet var luminanceSlider: GradientSiliderView!

   // private var socket: WebSocket!
    private var lastId: String = ""
    var service: NetService!
    
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
            
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device"
        print("service \(service.hostName!) ")
        color = UIColor.red
        colorWheel.delegate = self
        saturatonSlider.delegate = self
        luminanceSlider.delegate = self
        lastId = ""
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
        /*
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if !lastId.isEmpty {
            return
        }
        
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            lastId = randomString(length:4)
            let color = Color(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255))
            let req = Request(id: lastId, requestType: "update", resource: "color", content: color)
            
            var json: String
            do {
                let data = try JSONSerialization.data(withJSONObject: req.toJSONObj(), options: [])
                json = String(data: data, encoding: .utf8)!
            } catch {
                return
            }
            socket.write(string: json)
        }
 */
    }

    func requestColor() {
    }
}
