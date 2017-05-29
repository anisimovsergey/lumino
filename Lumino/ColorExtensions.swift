//
//  UIColorExtensions.swift
//  Lumino
//
//  Created by Sergey Anisimov on 03/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

extension Color {
    func toCGColor(min: Float, range: Float) -> CGColor {
        return self.toUIColor(min: min, range: range).cgColor
    }
    
    func toUIColor(min: Float, range: Float) -> UIColor {
        return UIColor(hue: CGFloat(self.h), saturation: CGFloat(self.s), brightness: CGFloat(self.v * range + min), alpha: CGFloat(1))
    }

}
