//
//  DeviceDetailsUIView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 23/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit
import Starscream
import SwiftHSVColorPicker

class DeviceDetailsUIViewController: UIViewController, WebSocketDelegate {

    @IBOutlet weak var textView: UITextView!
    var text = String()
    var socket: WebSocket!
    // IBOutlet for the ColorPicker
    @IBOutlet var colorPicker: SwiftHSVColorPicker!
    
    var selectedColor: UIColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // textView.text = text
        socket = WebSocket(url: URL(string: "ws://192.168.1.76/ws")!)
        socket.delegate = self
        socket.connect()
        colorPicker.setViewColor(selectedColor)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
      //  var a:CGFloat = 0
        selectedColor = colorPicker.color
        var bb:[CGFloat]! = selectedColor.cgColor.components
        var r:CGFloat = bb[0]
        if r < 0 {
            r = 0
        }
        var g:CGFloat = bb[1]
        if g < 0 {
            g = 0
        }
        var b:CGFloat = bb[2]
        if b < 0 {
            b = 0
        }

        //if selectedColor.getRed(&r, green: &g, blue: &b, alpha: &a){
            print("R: \(r) G: \(g) B: \(b)")
            socket.write(string: "{\"_type\": \"request\", \"requestType\": \"update\", \"resource\": \"color\",\"content\": {\"_type\": \"color\", \"r\": \(Int(r * 255)), \"g\": \(Int(g * 255)), \"b\": \(Int(b * 255))}}")
        //}
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
