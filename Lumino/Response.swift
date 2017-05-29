//
//  Response.swift
//  Lumino
//
//  Created by Sergey Anisimov on 27/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Response: Serializible {
    static let resourceId = "response"

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
