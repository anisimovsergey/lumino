//
//  Color.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class ColorSerializer : SerializerBase<Color> {
    static let hField: String = "h"
    static let sField: String = "s"
    static let vField: String = "v"
    
    func create(h: Float) -> (_ g: Float) -> (_ b: Float) -> Color {
        return { s in
            return { l in
                return Color(h: h, s: s, v: l)
            }
        }
    }

    override func deserializeImpl(_ con: DeserializationContext) -> Result<Color> {
        return create <^>
            con.getValue(ColorSerializer.hField) >>> cast <*>
            con.getValue(ColorSerializer.sField) >>> cast <*>
            con.getValue(ColorSerializer.vField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext,_ obj: Color) -> Optional<Error> {
        return
            con.setValue(ColorSerializer.hField, obj.h) <*>
            con.setValue(ColorSerializer.sField, obj.s) <*>
            con.setValue(ColorSerializer.vField, obj.v)
    }
}
