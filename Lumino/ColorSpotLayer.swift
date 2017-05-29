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
        self.strokeColor = UIColor.white.cgColor
        
        self.masksToBounds = false
        self.shadowColor = UIColor.black.cgColor
        self.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.shadowRadius = 4
        self.shadowOpacity = 0.8
        self.shadowPath = path.cgPath
    }

}
