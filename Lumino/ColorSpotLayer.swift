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
        self.strokeColor = UIColor.gray.cgColor
    }
}
