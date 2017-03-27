//
//  Response.swift
//  Lumino
//
//  Created by Sergey Anisimov on 27/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Response {
    let id: String
    let requestType: String
    let resource: String
}

extension Response {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let requestType = json["requestType"] as? String,
            let resource = json["resource"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.requestType = requestType
        self.resource = resource
    }
}
