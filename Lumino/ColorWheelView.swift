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
            setMarkerToHue()
        }
    }
    
    func setHueAnimated(_ hue: CGFloat) {
        colorHue = hue
        moveMarkerToHue()
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
        let padRadius = hueMarkerLayer.bounds.width / 2
        return (distanceSquared >= (circleRadius - padRadius) * (circleRadius - padRadius)) &&
               (distanceSquared <= (circleRadius + padRadius) * (circleRadius + padRadius))
    }

    func isTapOnMarker(_ position: CGPoint) -> Bool {
        let distanceSquared: CGFloat =
                (hueMarkerLayer.position.x - position.x) *
                (hueMarkerLayer.position.x - position.x) +
                (hueMarkerLayer.position.y - position.y) *
                (hueMarkerLayer.position.y - position.y)
        let padWidth = hueMarkerLayer.bounds.width
        return (distanceSquared <= padWidth * padWidth)
    }
    
    func setMarkerToHue() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        hueMarkerLayer.position = self.getHueMarkerPosition()
        let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
        hueMarkerLayer.fillColor = color.cgColor
        
        CATransaction.commit()
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
            self.hue = getHueFrom(position: position)
            delegate?.HueChanged(hue, wheel: self)
        }
    }

    func handleTapHue(_ gestureRecognizer: UITapGestureRecognizer) {
        let position: CGPoint = gestureRecognizer.location(in: self)
        if isTapOnCircle(position) {
            setHueAnimated(getHueFrom(position: position))
            delegate?.HueChanged(hue, wheel: self)
        }
    }

    func getHueMarkerPosition() -> CGPoint {
        let radians: CGFloat = colorHue * 2.0 * .pi
        let x = cos(radians) * circleRadius + circleCenter.x
        let y = -sin(radians) * circleRadius + circleCenter.y
        return CGPoint(x: x, y: y)
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let markerSize = round(bounds.width / 6)
        let lineWidth = round(markerSize / 8)

        circleRadius = (bounds.width - markerSize) / 2.0
        circleCenter = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        hueCircleLayer.frame = self.bounds
        hueCircleLayer.radius = circleRadius
        hueCircleLayer.lineWidth = lineWidth
        
        hueMarkerLayer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: markerSize, height: markerSize))
        hueMarkerLayer.lineWidth = round(lineWidth / 2)
        hueMarkerLayer.position = self.getHueMarkerPosition()
        
        colorSpotLayer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: circleRadius * 3/4, height: circleRadius * 3/4))
        colorSpotLayer.lineWidth = round(lineWidth / 2)
        colorSpotLayer.position =  CGPoint(x: bounds.width / 2 , y: bounds.height / 2)
    }
}

