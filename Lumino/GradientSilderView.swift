//
//  GradientSilderView.swift
//  Lumino
//
//  Created by Sergey Anisimov on 18/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

protocol GradientSiliderDelegate: class {
    func GradientChanged(_ gradient: CGFloat, slider: GradientSiliderView)
}

class GradientSiliderView: UIView {
    var frac: CGFloat = 0
    var lineLayer: CAGradientLayer!
    var markerLayer: CAShapeLayer!
    var colors: [UIColor]?
    var markerTapRecognizer: UITapGestureRecognizer!
    var markerPanRecognizer: UIPanGestureRecognizer!
    weak var delegate: GradientSiliderDelegate?

    var fraction: CGFloat {
        get {
            return frac
        }
        set {
            frac = newValue
            setMarkerToFrac()
        }
    }

    func setFracAnimated(_ frac: CGFloat) {
        self.frac = frac
        moveMarkerToFrac()
    }

    var uicolors: [UIColor]? {
        get {
            return self.colors
        }
        set(newColors) {
            self.colors = newColors
            lineLayer.colors = [colors?[0].cgColor as Any, colors?[1].cgColor as Any]
            markerLayer.fillColor = getSelectedColor().cgColor
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        lineLayer = ColorLineLayer()
        lineLayer.shouldRasterize = true
        lineLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        self.layer.addSublayer(lineLayer)

        markerLayer = ColorSpotLayer()
        self.layer.addSublayer(markerLayer)

        markerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapHue))
        self.addGestureRecognizer(markerTapRecognizer)

        markerPanRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanHue))
        self.addGestureRecognizer(markerPanRecognizer)
    }

    private func getMarkerPosition() -> CGPoint {
        let x = lineLayer.frame.origin.x + lineLayer.bounds.height * frac
        let y = self.bounds.height / 2
        return CGPoint(x: x, y: y)
    }

    func getSelectedColor() -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        colors?[0].getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        colors?[1].getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let red = (r1 * frac) + r2 * (1 - frac)
        let green = (g1 * frac) + g2 * (1 - frac)
        let blue = (b1 * frac) + b2 * (1 - frac)
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }

    func getFractionFrom(position: CGPoint) -> CGFloat {
        var fraction = (position.x - lineLayer.frame.origin.x) / lineLayer.bounds.height
        if fraction > 1 {
            fraction = 1
        } else if fraction < 0 {
            fraction = 0
        }
        return fraction
    }

    func setMarkerToFrac() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        markerLayer.position = self.getMarkerPosition()
        markerLayer.fillColor = getSelectedColor().cgColor

        CATransaction.commit()
    }

    func moveMarkerToFrac() {
        markerLayer.position = self.getMarkerPosition()
        markerLayer.fillColor = getSelectedColor().cgColor
    }

    func handlePanHue(_ gestureRecognizer: UIPanGestureRecognizer) {
        let position: CGPoint = gestureRecognizer.location(in: self)
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            self.fraction = getFractionFrom(position: position)
            delegate?.GradientChanged(frac, slider: self)
        }
    }

    func handleTapHue(_ gestureRecognizer: UITapGestureRecognizer) {
        let position: CGPoint = gestureRecognizer.location(in: self)
        setFracAnimated(getFractionFrom(position: position))
        delegate?.GradientChanged(frac, slider: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let markerSize = round(bounds.width / 7)
        let lineWidth = round(markerSize / 8)

        lineLayer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: lineWidth, height: self.bounds.width - markerSize))
        lineLayer.position = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)

        markerLayer.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: markerSize, height: markerSize))
        markerLayer.lineWidth = round(lineWidth / 2)
        markerLayer.position = self.getMarkerPosition()
    }

}
