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
    static let uniqueNameField: String = "uniqueName"
    static let deviceNameField: String = "deviceName"
    
    func create(isOn: Bool) -> (_ uniqueName: String) -> (_ deviceName: String) -> Settings {
        return {
            uniqueName in {
                deviceName in
                return Settings(isOn: isOn, uniqueName: uniqueName, deviceName: deviceName)
            }
        }
    }
        
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Settings> {
        return create <^>
            con.getValue(SettingsSerializer.isOnField) >>> cast <*>
            con.getValue(SettingsSerializer.uniqueNameField) >>> cast <*>
            con.getValue(SettingsSerializer.deviceNameField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext, _ obj: Settings) -> Optional<Error> {
        return
            con.setValue(SettingsSerializer.isOnField, obj.isOn) <*>
            con.setValue(SettingsSerializer.uniqueNameField, obj.uniqueName) <*>
            con.setValue(SettingsSerializer.deviceNameField, obj.deviceName)
    }
}
