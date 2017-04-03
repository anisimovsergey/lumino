//
//  GradientSilder.swift
//  Lumino
//
//  Created by Sergey Anisimov on 18/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

protocol ColorWheelDelegate: class {
    func HueChanged(_ hue: CGFloat, wheel: ColorWheelView)
}

class ColorWheelView: UIView, UIGestureRecognizerDelegate {
    private var colorHue: CGFloat = 0
    private var circleCenter: CGPoint = CGPoint.init()
    private var circleRadius: CGFloat = 0

    private var hueCircleLayer: HueCircleLayer!
    private var hueMarkerLayer: ColorSpotLayer!
    private var colorSpotLayer: ColorSpotLayer!
    
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
    
    var spotColor: CGColor {
        get {
            return colorSpotLayer.fillColor!
        }
        set {
            colorSpotLayer.fillColor = newValue
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
        self.layer.addSublayer(hueCircleLayer)
        
        hueMarkerLayer = ColorSpotLayer();
        self.layer.addSublayer(hueMarkerLayer)
        
        colorSpotLayer = ColorSpotLayer()
        self.layer.addSublayer(colorSpotLayer)
                
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
        hueMarkerLayer.fillColor = color.cgColor
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
            hueMarkerLayer.fillColor = color.cgColor
            
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
        hueCircleLayer.setNeedsDisplay()

        hueMarkerLayer.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 44, height: 44))
        hueMarkerLayer.position = self.getHueMarkerPosition()
        
        colorSpotLayer.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: circleRadius * 3/4, height: circleRadius * 3/4))
        colorSpotLayer.position =  CGPoint(x: bounds.width/2 , y: bounds.height/2)
    }
 
}

