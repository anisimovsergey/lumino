//
//  UIColorExtensions.swift
//  Lumino
//
//  Created by Sergey Anisimov on 03/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

typealias HSLHandler = (_ h : CGFloat, _ s : CGFloat, _ l : CGFloat)  -> Void
typealias RGBHandler = (_ r : CGFloat, _ g : CGFloat, _ b : CGFloat)  -> Void

extension UIColor {
    func getHue(_ hslHandler: HSLHandler) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var l: CGFloat = 0
        var a: CGFloat = 0
        
        self.getHue(&h, saturation: &s, brightness: &l, alpha: &a)
        hslHandler(h, s, l)
    }
    
    func getRgb(_ rgbHandler: RGBHandler) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        rgbHandler(r, g, b)
    }
    
    func toColor() -> Color {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(r: UInt8(r * 255), g: UInt8(g * 255), b: UInt8(b * 255))
    }
}

extension Color {
    func toUIColor() -> UIColor {
        return UIColor.init(red: CGFloat(self.r) / 255.0, green: CGFloat(self.g) / 255.0, blue: CGFloat(self.b) / 255.0, alpha: 1.0)
    }
}
