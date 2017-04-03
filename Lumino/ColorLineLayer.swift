//
//  ColorLineLayer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 02/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class ColorLineLayer: CAGradientLayer {
        
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let r: CGFloat = self.bounds.width / 2
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: r)
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        mask.fillColor = UIColor.black.cgColor
        self.mask = mask
    }
}
