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
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = UIColor.black.cgColor
        self.mask = mask
    }

}
