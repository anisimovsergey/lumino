//
//  SettingsSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class SettingsSerializer: SerializerBase<Settings> {
    static let deviceNameField: String = "device_name"
    
    func create(deviceName: String) -> Settings {
        return Settings(deviceName: deviceName)
    }
    
    override var type: String {
        get {
            return "settings"
        }
    }
    
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Settings> {
        return create <^>
            con.getValue(SettingsSerializer.deviceNameField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext, _ obj: Settings) -> Optional<Error> {
        return con.setValue(SettingsSerializer.deviceNameField, obj.deviceName)
    }
}