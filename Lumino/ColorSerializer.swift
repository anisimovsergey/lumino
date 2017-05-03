//
//  Color.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class ColorSerializer : SerializerBase<Color> {
    static let rField: String = "r"
    static let gField: String = "g"
    static let bField: String = "b"
    
    func create(r: UInt8) -> (_ g: UInt8) -> (_ b: UInt8) -> Color {
        return { g in
            return { b in
                return Color(r: r, g: g, b: b)
            }
        }
    }

    override var type: String {
        get {
            return "color"
        }
    }

    override func deserializeImpl(_ con: DeserializationContext) -> Result<Color> {
        return create <^>
            con.getValue(ColorSerializer.rField) >>> cast <*>
            con.getValue(ColorSerializer.gField) >>> cast <*>
            con.getValue(ColorSerializer.bField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext,_ obj: Color) -> Optional<Error> {
        return
            con.setValue(ColorSerializer.rField, obj.r) <*>
            con.setValue(ColorSerializer.gField, obj.g) <*>
            con.setValue(ColorSerializer.bField, obj.b)
    }
}
