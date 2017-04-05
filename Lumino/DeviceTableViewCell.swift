//
//  DeviceTableViewCell.swift
//  Lumino
//
//  Created by Sergey Anisimov on 05/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

import UIKit

class DeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var bioLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.gray
        selectedBackgroundView = bgColorView
        
        let bgColorView2 = UIView()
        bgColorView2.backgroundColor = UIColor.init(red: 219/256, green: 219/256, blue: 219/256, alpha: 1)
        backgroundView = bgColorView2
        
      //  layoutMargins = UIEdgeInsetsMake(8, 8, 8, 8)
    }
 
   
    
    override func layoutSubviews() {
        super.layoutSubviews()

        
        
        backgroundView?.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(5, 5, 0, 5))

        selectedBackgroundView?.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(5, 5, 0, 5))

        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, UIEdgeInsetsMake(5, 5, 0, 5))
    }
}
