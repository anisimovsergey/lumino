//
//  Event.swift
//  Lumino
//
//  Created by Sergey Anisimov on 27/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Event {
    let eventType: String
}

extension Event {
    init?(json: [String: Any]) {
        guard
            let eventType = json["eventType"] as? String
        else {
                return nil
        }
        self.eventType = eventType
    }
}
