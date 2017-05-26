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
    let deviceName: String
}
