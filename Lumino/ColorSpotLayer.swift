//
//  ColorSpotLayer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 19/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class ColorSpotLayer: CAShapeLayer {
    
    override func layoutSublayers() {
        super.layoutSublayers()
        let path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: lineWidth, dy: lineWidth))
        self.path = path.cgPath
        self.strokeColor = UIColor.init(red: 219/256, green: 219/256, blue: 219/256, alpha: 1).cgColor
    }
}
