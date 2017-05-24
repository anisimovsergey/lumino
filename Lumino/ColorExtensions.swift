//
//  UIColorExtensions.swift
//  Lumino
//
//  Created by Sergey Anisimov on 03/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import UIKit

extension Color {
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
    
    func toUIColor() -> UIColor {
        return UIColor(hue: CGFloat(self.h), saturation: CGFloat(self.s), brightness: CGFloat(self.v), alpha: CGFloat(1))
    }

}
