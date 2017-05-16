//
//  SettingsViewController.swift
//  Lumino
//
//  Created by Sergey Anisimov on 07/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation
import UIKit
import MulticastDelegateSwift

class SettingsViewController: UIViewController, WebSocketConnectionDelegate {
    @IBOutlet var name: UITextField!
    @IBOutlet var save: UIBarButtonItem!
    var device: DeviceListItem!
    
    @IBAction func cancelEdit(sender: AnyObject) {
        if (!self.device.client.isConnected) {
            self.presentedViewController?.performSegue(withIdentifier: "unwindToDetails", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        let settings = Settings(deviceName: name.text!)
        _ = device.client.updateSettings(settings)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        name.text = self.device.name
        self.device.client.connectionDelegate += self
        if (!self.device.client.isConnected) {
            showDisconnected()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.device.client.connectionDelegate -= self
    }

    func websocketDidConnect(client: WebSocketClient) {
        self.presentedViewController?.performSegue(withIdentifier: "unwindToSettings", sender: self)
        self.save.isEnabled = true
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        showDisconnected()
    }
    
    @IBAction func unwindToSettings(_ segue:UIStoryboardSegue) {
        print("unwind to settings")
    }
    
    func showDisconnected() {
        self.performSegue(withIdentifier: "disconnected", sender:self)
        self.save.isEnabled = false
    }
}
