//
//  Color.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Color : JSONSerializible {
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

extension Color {
    init?(json: [String: Any]) {
        guard
            let r = json["r"] as? UInt8,
            let g = json["g"] as? UInt8,
            let b = json["b"] as? UInt8
        else {
            return nil
        }
        self.r = r
        self.g = g
        self.b = b
    }
    
    func toJSONObj() -> Any {
        return [
            "_type": "color",
            "r": self.r,
            "g": self.g,
            "b": self.b,
        ]
    }
}
