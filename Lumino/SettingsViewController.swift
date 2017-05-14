//
//  SettingsViewController.swift
//  Lumino
//
//  Created by Sergey Anisimov on 07/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var name: UITextField!
    var device: DeviceListItem!
    
    @IBAction func cancelEdit(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func save(sender: AnyObject) {
        let settings = Settings(deviceName: name.text!)
        _ = device.client.updateSettings(settings)
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        name.text = self.device.name
    }    
}
