//
//  ColorSpotLayer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 19/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class ColorSpot: CALayer {
    let lineWidth: CGFloat = 4;
    let strokeColor: UIColor =  UIColor.init(red: 219/256, green: 219/256, blue: 219/256, alpha: 1)
    
    override func draw(in context: CGContext) {
        context.addEllipse(in: self.bounds.insetBy(dx: lineWidth, dy: lineWidth))
        context.setLineWidth(lineWidth)
        context.setStrokeColor(strokeColor.cgColor)
        context.strokePath()
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateMask()
    }
    
    func updateMask() {
        let path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: lineWidth, dy: lineWidth))
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        mask.fillColor = UIColor.black.cgColor
        self.mask = mask
    }
}
