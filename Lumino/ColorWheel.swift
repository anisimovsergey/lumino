//
//  GradientSilder.swift
//  Lumino
//
//  Created by Sergey Anisimov on 18/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

class HueCircleLayer: CALayer {
    let segmentsNum: Int = 256
    let lineWidth: CGFloat = 6
    var radius: CGFloat = 0
    
    override func draw(in context: CGContext) {
        let sliceAngle: CGFloat = 2.0 * .pi / CGFloat(segmentsNum)
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint(x: 0, y: 0), radius: radius, startAngle: -sliceAngle / 2.0, endAngle: sliceAngle / 2.0 + 1.0e-2, clockwise: false, transform: .identity)
        context.translateBy(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        context.setLineWidth(lineWidth)
        for i in 0..<self.segmentsNum {
            let hue = CGFloat(Float(i) / Float(self.segmentsNum))
            let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
            context.addPath(path)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
            context.rotate(by: -sliceAngle)
        }
    }
}

protocol ColorWheelDelegate: class {
    func HueChanged(_ hue: CGFloat, wheel: ColorWheel)
}

class ColorWheel: UIView, UIGestureRecognizerDelegate {
    private var colorHue: CGFloat = 0
    private var circleCenter: CGPoint = CGPoint.init()
    private var circleRadius: CGFloat = 0

    private var hueCircleLayer: HueCircleLayer!
    private var hueMarkerLayer: CALayer!
    private var panStarted: Bool = false;
    
    private var hueTapGestureRecognizer: UITapGestureRecognizer!
    private var huePanGestureRecognizer: UIPanGestureRecognizer!
    
    weak var delegate: ColorWheelDelegate?
    
    var hue: CGFloat {
        get {
            return colorHue
        }
        set {
            colorHue = newValue
            moveMarkerToHue()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        hueCircleLayer = HueCircleLayer()
        hueCircleLayer.contentsScale = UIScreen.main.scale
        hueCircleLayer.setNeedsDisplay()
        self.layer.addSublayer(hueCircleLayer)
        
        hueMarkerLayer = ColorSpot();
        hueMarkerLayer.contentsScale = UIScreen.main.scale
        hueMarkerLayer.setNeedsDisplay()
        self.layer.addSublayer(hueMarkerLayer)
                
        hueTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapHue))
        self.addGestureRecognizer(hueTapGestureRecognizer)
        
        huePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanHue))
        self.addGestureRecognizer(huePanGestureRecognizer)
    }
    
    func isTapOnCircle(_ position: CGPoint) -> Bool {
        let distanceSquared: CGFloat =
                (circleCenter.x - position.x) *
                (circleCenter.x - position.x) +
                (circleCenter.y - position.y) *
                (circleCenter.y - position.y)
        return (distanceSquared >= (circleRadius - 22) * (circleRadius - 22)) &&
               (distanceSquared <= (circleRadius + 22) * (circleRadius + 22))
    }

    func isTapOnMarker(_ position: CGPoint) -> Bool {
        let distanceSquared: CGFloat =
                (hueMarkerLayer.position.x - position.x) *
                (hueMarkerLayer.position.x - position.x) +
                (hueMarkerLayer.position.y - position.y) *
                (hueMarkerLayer.position.y - position.y)
        return (distanceSquared <= 44 * 44)
    }
    
    func moveMarkerToHue() {
        // Getting the previous position
        var position: CGPoint = hueMarkerLayer.position
        if (hueMarkerLayer.presentation() != nil) {
            position = (hueMarkerLayer.presentation()?.position)!
        }
        
        // Setting the new position
        hueMarkerLayer.position = self.getHueMarkerPosition()

        // Creating the animation path
        let path: CGMutablePath = CGMutablePath()
        let oldHue = getHueFrom(position: position)
        if (abs(colorHue - oldHue) < 0.5) {
            path.addArc(center: circleCenter, radius: CGFloat(circleRadius), startAngle: -oldHue * 2.0 * .pi, endAngle: -colorHue * 2.0 * .pi, clockwise: colorHue > oldHue, transform: .identity)
        } else {
            path.addArc(center: circleCenter, radius: CGFloat(circleRadius), startAngle: -oldHue * 2.0 * .pi, endAngle: -colorHue * 2.0 * .pi, clockwise: colorHue < oldHue, transform: .identity)
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        hueMarkerLayer.removeAllAnimations()
        hueMarkerLayer.add(animation, forKey: "position")
        
        let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
        hueMarkerLayer.backgroundColor = color.cgColor
    }
    
    func getHueFrom(position: CGPoint) -> CGFloat {
        let radians: CGFloat = atan2(circleCenter.y - position.y, position.x - circleCenter.x)
        var hue = radians / (2.0 * .pi)
        if hue < 0.0 {
            hue += 1.0
        }
        return hue
    }
    
    func handlePanHue(_ gestureRecognizer: UIPanGestureRecognizer) {
        let position: CGPoint = gestureRecognizer.location(in: self)
        if gestureRecognizer.state == .began {
            panStarted = isTapOnMarker(position)
        }
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed) &&
            panStarted {

            colorHue = getHueFrom(position: position)
            delegate?.HueChanged(colorHue, wheel: self)

            let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            hueMarkerLayer.position = self.getHueMarkerPosition()
            hueMarkerLayer.backgroundColor = color.cgColor
            
            CATransaction.commit()
        }
    }

    func handleTapHue(_ gestureRecognizer: UITapGestureRecognizer) {
        let position: CGPoint = gestureRecognizer.location(in: self)
        if !isTapOnCircle(position) {
            return
        }

        colorHue = getHueFrom(position: position)
        delegate?.HueChanged(colorHue, wheel: self)

        moveMarkerToHue()
    }

    func getHueMarkerPosition() -> CGPoint {
        let radians: CGFloat = colorHue * 2.0 * .pi
        let x = cos(radians) * circleRadius + circleCenter.x
        let y = -sin(radians) * circleRadius + circleCenter.y
        return CGPoint(x: x, y: y)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let minSide: CGFloat = CGFloat(min(self.bounds.size.width, self.bounds.size.height))
        circleRadius = (minSide - 44) / 2.0
        circleCenter = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        hueCircleLayer.radius = circleRadius
        hueCircleLayer.frame = self.bounds

        hueMarkerLayer.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 44, height: 44))
        hueMarkerLayer.position = self.getHueMarkerPosition()
    }
 
}

