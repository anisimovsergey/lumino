//
//  ColorSpotView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 19/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class ColorSpotView: UIView {
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return ColorSpot.self
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.setNeedsDisplay()
    }
}
