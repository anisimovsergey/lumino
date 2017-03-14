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
    var lineLayer: CAShapeLayer!
    
    var hueGestureRecognizer: UILongPressGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func CreateLineLayer() -> CAShapeLayer {
        let width: CGFloat = 130
        let height: CGFloat = 1
        
        let lineLayer = CAShapeLayer()
        lineLayer.frame = CGRect(x: 0, y: 0,
                                  width: width, height: height)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: height / 2))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        
        lineLayer.path = path
        lineLayer.strokeColor = UIColor.red.cgColor
        lineLayer.lineWidth = 1
        lineLayer.anchorPoint = CGPoint(x: 0, y: height / 2)
        return lineLayer
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
        
        lineLayer = CreateLineLayer()
        lineLayer.contentsScale = UIScreen.main.scale
        lineLayer.setNeedsDisplay()
        self.layer.addSublayer(lineLayer)
        
        hueGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleDragHue))
        hueGestureRecognizer.minimumPressDuration = 0;
        hueGestureRecognizer.delegate = self
        self.addGestureRecognizer(hueGestureRecognizer)
        
        backgroundColor = UIColor.init(red: 39/256, green: 46/256, blue: 65/256, alpha: 1.0)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if ( gestureRecognizer == hueGestureRecognizer )
        {
            let position: CGPoint = gestureRecognizer.location(in: self)
            let distanceSquared: CGFloat = (center.x - position.x) * (center.x - position.x) + (center.y - position.y) * (center.y - position.y)
            return ((radius - thickness) * (radius - thickness) < distanceSquared) && (distanceSquared <= radius * radius)
        }
        return true
    }
    
    func move(_ layer: CALayer, from oldHue: CGFloat, to newHue: CGFloat, toRad toRad:CGFloat) {
        let path: CGMutablePath = CGMutablePath()
        let center = CGPoint(x: CGFloat(self.bounds.size.width / 2.0), y: CGFloat(self.bounds.size.height / 2.0))

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
        animation.duration = 1
        layer.add(animation, forKey: "animate position along path")
        

        let transformAnimation = CABasicAnimation(keyPath: "transform")
        let trans: CATransform3D = CATransform3DMakeRotation(-toRad, 0.0, 0.0, 1.0);
        transformAnimation.toValue = NSValue(caTransform3D: trans)
        transformAnimation.duration = 1
        lineLayer.add(transformAnimation, forKey: "transformAnimation")

    }
    
    
    func handleDragHue(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .began) || (gestureRecognizer.state == .changed) {
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
           // lineLayer.transform = CATransform3DMakeRotation(-radians, 0.0, 0.0, 1.0);

            move(hueMarkerLayer, from: oldColorHue, to: colorHue, toRad: radians)
            
            let color = UIColor(hue: colorHue, saturation: CGFloat(1), brightness: CGFloat(1), alpha: CGFloat(1))
            hueMarkerLayer.backgroundColor = color.cgColor
            colorCenterLayer.backgroundColor = color.cgColor
            lineLayer.strokeColor = color.cgColor
            
            
        }
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
        
        lineLayer.frame = CGRect(origin: CGPoint(x: CGFloat(0), y: CGFloat(0)), size: CGSize(width: radius, height: lineLayer.frame.height))
        lineLayer.position = center
    }
 
}

