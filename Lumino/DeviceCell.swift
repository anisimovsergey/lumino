//
//  UiDeviceCell.swift
//  Lumino
//
//  Created by Sergey Anisimov on 24/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    @IBOutlet var colorView: UIView!
    @IBOutlet var label: UILabel!
    @IBOutlet var isOn: UISwitch!
    private var tintView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if self.tintView == nil {
            tintView = UIView()
            tintView.frame = self.bounds
            tintView.backgroundColor = UIColor.white
            self.addSubview(self.tintView)
        }
        if selected {
            UIView.animate(withDuration: 0.2, animations: {
                self.tintView.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                self.tintView.alpha = 0.0
            })
        }
    }
    
}

