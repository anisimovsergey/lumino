//
//  Request.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Request : JSONSerializible {
    let id: String
    let requestType: String
    let resource: String
    let content: JSONSerializible?
}

extension Request {
    func toJSONObj() -> Any {
        var res: [String: Any] = [
            "_type": "request",
            "id": self.id,
            "requestType": self.requestType,
            "resource": self.resource
        ]
        if self.content != nil {
            res["content"] =  self.content?.toJSONObj()
        }
        return res
    }
}
