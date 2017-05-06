//
//  Color.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Color: Serializible, Equatable {
    static let resourceId = "color"
    
    let r: UInt8
    let g: UInt8
    let b: UInt8
    
    public static func == (lhs: Color, rhs: Color) -> Bool {
        return  (lhs.r == rhs.r) &&
                (lhs.g == rhs.g) &&
                (lhs.b == rhs.b)
    }
}
