//
//  SettingsSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class SettingsSerializer: SerializerBase<Settings> {
    static let isOnField: String = "isOn"
    static let deviceNameField: String = "deviceName"
    
    func create(isOn: Bool) -> (_ deviceName: String) -> Settings {
        return { deviceName in
            return Settings(isOn: isOn, deviceName: deviceName)
        }
    }
    
    func create(h: Float) -> (_ s: Float) -> (_ l: Float) -> Color {
        return { s in
            return { l in
                return Color(h: h, s: s, v: l)
            }
        }
    }
    
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Settings> {
        return create <^>
            con.getValue(SettingsSerializer.isOnField) >>> cast <*>
            con.getValue(SettingsSerializer.deviceNameField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext, _ obj: Settings) -> Optional<Error> {
        return
            con.setValue(SettingsSerializer.isOnField, obj.isOn) <*>
            con.setValue(SettingsSerializer.deviceNameField, obj.deviceName)
    }
}
