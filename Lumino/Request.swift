//
//  Request.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Request: Serializible {
    static let resourceId = "request"
    
    let id: String
    let requestType: String
    let resource: String
    let content: Serializible?

    init(id: String, requestType: String, resource: String) {
        self.init(id: id, requestType: requestType, resource: resource, content: nil)
    }

    init(id: String, requestType: String, resource: String, content: Serializible?) {
        self.id = id
        self.requestType = requestType
        self.resource = resource
        self.content = content
    }
}
