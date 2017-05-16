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
    
    let h: Float
    let s: Float
    let l: Float
    
    public static func == (lhs: Color, rhs: Color) -> Bool {
        return  (lhs.h == rhs.h) &&
                (lhs.s == rhs.s) &&
                (lhs.l == rhs.l)
    }
}
