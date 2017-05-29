//
//  Color.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Settings: Serializible {
    static let resourceId = "settings"

    let isOn: Bool
    let uniqueName: String
    let deviceName: String

    init(isOn:Bool, uniqueName:String, deviceName:String) {
        self.isOn = isOn
        self.uniqueName = uniqueName
        self.deviceName = deviceName
    }

    init(isOn:Bool, deviceName:String) {
        self.isOn = isOn
        self.uniqueName = ""
        self.deviceName = deviceName
    }

}
