//
//  Event.swift
//  Lumino
//
//  Created by Sergey Anisimov on 27/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Event: Serializible {
    let eventType: String
    let resource: String
    let content: Serializible?
}
