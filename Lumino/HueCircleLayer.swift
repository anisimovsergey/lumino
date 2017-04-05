//
//  HueCircleLayer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 02/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class HueCircleLayer: CALayer {
    private let segmentsNum: Int = 256
    
    override init() {
        super.init()
        isOpaque = true
        contentsScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var radius: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var lineWidth: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in context: CGContext) {
        let sliceAngle: CGFloat = 2.0 * .pi / CGFloat(segmentsNum)
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: 0), radius: radius,
                    startAngle: -sliceAngle / 2.0,
                    endAngle: sliceAngle / 2.0 + 1.0e-2,
                    clockwise: false, transform: .identity)
        context.translateBy(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        context.setLineWidth(lineWidth + 2)
        for i in 0..<self.segmentsNum {
            let hue = CGFloat(Float(i) / Float(self.segmentsNum))
            let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            context.addPath(path)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
            context.rotate(by: -sliceAngle)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        updateMask()
    }
    
    func updateMask() {
        let path: CGMutablePath = CGMutablePath()
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        
        let rp = radius + lineWidth / 2
        path.addPath(UIBezierPath(ovalIn: CGRect(x: -rp, y: -rp, width: rp * 2, height: rp * 2)).cgPath, transform: transform)
        
        let rm = radius - lineWidth / 2
        path.addPath(UIBezierPath(ovalIn: CGRect(x: -rm, y: -rm, width: rm * 2, height: rm * 2)).cgPath, transform: transform)
        
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path
        mask.fillColor = UIColor.black.cgColor
        mask.fillRule = kCAFillRuleEvenOdd
        self.mask = mask
    }
}
