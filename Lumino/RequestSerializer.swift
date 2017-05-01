//
//  RequestSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class RequestSerializer: SerializerBase<Request> {
    static let idField: String = "id"
    static let requestTypeField: String = "requestType"
    static let resourceField: String = "resource"
    static let contentField: String = "content"
    
    func create(id: String) -> (_ requestType: String) -> (_ resource: String) -> (_ content: Serializible?) -> Request {
        return { requestType in
            return { resource in
                return { content in
                    return Request(id: id, requestType: requestType, resource: resource, content: content) as Request
                }
            }
        }
    }
    
    override var type: String {
        get {
            return "request"
        }
    }
    
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Request> {
        return create <^>
            con.getValue(RequestSerializer.idField) >>> cast <*>
            con.getValue(RequestSerializer.requestTypeField) >>> cast <*>
            con.getValue(RequestSerializer.resourceField) >>> cast <*>
            con.getOptionalObject(RequestSerializer.contentField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext,_ obj: Request) -> Optional<Error> {
        return
            con.setValue(RequestSerializer.idField, obj.id) <*>
                con.setValue(RequestSerializer.requestTypeField, obj.requestType) <*>
                con.setValue(RequestSerializer.resourceField, obj.resource) <*>
                con.setOptionalObject(RequestSerializer.contentField, obj.content)
    }
}
