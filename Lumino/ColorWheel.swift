import UIKit

class HueMarker: CALayer {
    let circleWidth: CGFloat = 4;
    
    override func draw(in context: CGContext) {
        context.setLineWidth(circleWidth)
        let c = UIColor.init(red: 219/256, green: 219/256, blue: 219/256, alpha: 1)
        context.setStrokeColor(c.cgColor)
        let rect = self.bounds.insetBy(dx: self.circleWidth, dy: self.circleWidth)
        context.addEllipse(in: rect)
        context.strokePath()
    }
}

class ColorCenter: CALayer {
    let circleWidth: CGFloat = 4;
    
    override func draw(in context: CGContext) {
        context.setLineWidth(circleWidth)
        context.setStrokeColor(UIColor.gray.withAlphaComponent(0.5).cgColor)
        let rect = self.bounds.insetBy(dx: self.circleWidth / 2, dy: self.circleWidth / 2)
        context.addEllipse(in: rect)
        context.strokePath()
    }
}

class HueCircleLayer: CALayer {
    let segmentsNum: Int = 256
    let circleWidth: CGFloat = 0.02
    var radius: CGFloat = 0
    
    
    override func draw(in context: CGContext) {
        let thickness: CGFloat = radius * circleWidth
        let sliceAngle: CGFloat = 2.0 * .pi / CGFloat(self.segmentsNum)
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint(x: CGFloat(0.0), y: CGFloat(0.0)), radius: CGFloat(radius - thickness), startAngle: CGFloat(-sliceAngle / 2.0), endAngle: CGFloat(sliceAngle / 2.0 + 1.0e-2), clockwise: false, transform: .identity)
        context.translateBy(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let incrementAngle = 2.0 * .pi / Float(self.segmentsNum)
        context.setLineWidth(thickness)
        for i in 0..<self.segmentsNum {
            let hue = CGFloat(Float(i) / Float(self.segmentsNum))
            let color = UIColor(hue: hue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            context.addPath(path)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
            context.rotate(by: CGFloat(-incrementAngle))
        }
    }
    
}

class ColorWheel: UIView, UIGestureRecognizerDelegate {
    var colorHue: CGFloat = 0;
    var radius: CGFloat = 0;
    var thickness: CGFloat = 0;

    var hueCircleLayer: HueCircleLayer!
    var hueMarkerLayer: CALayer!
    var colorCenterLayer: CALayer!
    var panStarted: Bool = false;
    
    var hueTapGestureRecognizer: UITapGestureRecognizer!
    var huePanGestureRecognizer: UIPanGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open func AA() {
        hueCircleLayer = HueCircleLayer()
        hueCircleLayer.contentsScale = UIScreen.main.scale
        hueCircleLayer.setNeedsDisplay()
        self.layer.addSublayer(hueCircleLayer)
        
        hueMarkerLayer = HueMarker();
        hueMarkerLayer.contentsScale = UIScreen.main.scale
        hueMarkerLayer.setNeedsDisplay()
        self.layer.addSublayer(hueMarkerLayer)
        
        colorCenterLayer = ColorCenter()
        colorCenterLayer.contentsScale = UIScreen.main.scale
        colorCenterLayer.setNeedsDisplay()
        self.layer.addSublayer(colorCenterLayer)
        
        hueTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapHue))
        self.addGestureRecognizer(hueTapGestureRecognizer)
        
        huePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanHue))
        self.addGestureRecognizer(huePanGestureRecognizer)

        
        backgroundColor = UIColor.init(red: 39/256, green: 46/256, blue: 65/256, alpha: 1.0)
    }
    
    func isTapOnCircle(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            let position: CGPoint = gestureRecognizer.location(in: self)
            let distanceSquared: CGFloat = (center.x - position.x) * (center.x - position.x) + (center.y - position.y) * (center.y - position.y)
            let res: Bool = (distanceSquared >= (radius - 22) * (radius - 22)) &&
                            (distanceSquared <= (radius + 22) * (radius + 22))
            return res
    }
    
    func move(_ layer: CALayer, from oldHue: CGFloat, to newHue: CGFloat) {
        let path: CGMutablePath = CGMutablePath()
        let center = CGPoint(x: CGFloat(self.bounds.size.width / 2.0), y: CGFloat(self.bounds.size.height / 2.0))
        
        let position: CGPoint = (layer.presentation()?.position)!
        var from_radians: CGFloat = atan2(center.y - position.y, position.x - center.x)
        from_radians = from_radians / (2.0 * .pi)
        if from_radians < 0.0 {
            from_radians += 1.0
        }
        let oldHue = from_radians
        if (newHue > oldHue) {
            if (newHue - oldHue < 0.5) {
                path.addArc(center: center, radius: CGFloat(radius), startAngle: -oldHue * 2.0 * .pi, endAngle: -newHue * 2.0 * .pi, clockwise: true, transform: .identity)
            } else {
                path.addArc(center: center, radius: CGFloat(radius), startAngle: -oldHue * 2.0 * .pi, endAngle: -newHue * 2.0 * .pi, clockwise: false, transform: .identity)
            }
        } else {
            if (oldHue - newHue < 0.5) {
                path.addArc(center: center, radius: CGFloat(radius), startAngle: -oldHue * 2.0 * .pi, endAngle: -newHue * 2.0 * .pi, clockwise: false, transform: .identity)
            } else {
                path.addArc(center: center, radius: CGFloat(radius), startAngle: -oldHue * 2.0 * .pi, endAngle: -newHue * 2.0 * .pi, clockwise: true, transform: .identity)
            }
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = path
        layer.removeAllAnimations()
        layer.add(animation, forKey: "animate position along path")
    }
    
    func handlePanHue(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            panStarted = isTapOnCircle(gestureRecognizer) // Not on circle but on the marker
        }
        if (gestureRecognizer.state == .began || gestureRecognizer.state == .changed) &&
            panStarted {
            let position: CGPoint = gestureRecognizer.location(in: self)
            let radians: CGFloat = atan2(center.y - position.y, position.x - center.x)
            colorHue = radians / (2.0 * .pi)
            if colorHue < 0.0 {
                colorHue += 1.0
            }
            let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            hueMarkerLayer.position = self.getHueMarkerPosition()
            hueMarkerLayer.backgroundColor = color.cgColor
            colorCenterLayer.backgroundColor = color.cgColor
            
            CATransaction.commit()
        }
    }

    
    func handleTapHue(_ gestureRecognizer: UITapGestureRecognizer) {
        if !isTapOnCircle(gestureRecognizer) {
            return
        }
        
            let position: CGPoint = gestureRecognizer.location(in: self)
            let distanceSquared: CGFloat = (center.x - position.x) * (center.x - position.x) + (center.y - position.y) * (center.y - position.y)
            if distanceSquared < 1.0e-3 {
                return
            }
            let radians: CGFloat = atan2(center.y - position.y, position.x - center.x)
            let oldColorHue = colorHue
            colorHue = radians / (2.0 * .pi)
            if colorHue < 0.0 {
                colorHue += 1.0
            }
            hueMarkerLayer.position = self.getHueMarkerPosition()
            move(hueMarkerLayer, from: oldColorHue, to: colorHue)
            
            let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            hueMarkerLayer.backgroundColor = color.cgColor
            colorCenterLayer.backgroundColor = color.cgColor
    }

    func getHueMarkerPosition() -> CGPoint {
        let radians: CGFloat = colorHue * 2.0 * .pi
        center = CGPoint(x: CGFloat(self.bounds.size.width / 2.0), y: CGFloat(self.bounds.size.height / 2.0))
    
        let x = cos(radians) * radius + center.x
        let y = -sin(radians) * radius + center.y
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let resolution: CGFloat = CGFloat(min(self.bounds.size.width, self.bounds.size.height))
        radius = resolution * 0.8 / 2.0
        
        hueCircleLayer.radius = radius
        radius = radius - 3
        hueCircleLayer.frame = self.bounds
        
        thickness = 0.7 * radius
        
        center = CGPoint(x: CGFloat(self.bounds.size.width / 2.0), y: CGFloat(self.bounds.size.height / 2.0))
       
        hueMarkerLayer.bounds = CGRect(origin: CGPoint(x: CGFloat(0), y: CGFloat(0)), size: CGSize(width: 34, height: 34))
            
        hueMarkerLayer.position = self.getHueMarkerPosition()
        
        let path: CGMutablePath = CGMutablePath()
        let rect = hueMarkerLayer.bounds.insetBy(dx: 4, dy: 4)

        path.addEllipse(in: rect)
        
        let fillLayer = CAShapeLayer()

        fillLayer.frame = hueMarkerLayer.bounds
        fillLayer.path = path
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        hueMarkerLayer.mask = fillLayer
        
        // Color center layer
        colorCenterLayer.bounds = CGRect(origin: CGPoint(x: CGFloat(0), y: CGFloat(0)), size: CGSize(width: 68, height: 68))
        colorCenterLayer.position = center
        
        let path2: CGMutablePath = CGMutablePath()
        
        path2.addEllipse(in: colorCenterLayer.bounds)
        
        let fillLayer2 = CAShapeLayer()
        
        fillLayer2.frame = colorCenterLayer.bounds
        fillLayer2.path = path2
        fillLayer2.fillRule = kCAFillRuleEvenOdd
        fillLayer2.fillColor = UIColor.black.cgColor
        colorCenterLayer.mask = fillLayer2
    }
 
}

