//
//  ResponseSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class ResponseSerializer: SerializerBase<Response> {
    static let idField: String = "id"
    static let requestTypeField: String = "requestType"
    static let resourceField: String = "resource"
    static let contentField: String = "content"
    
    func create(id: String) -> (_ requestType: String) -> (_ resource: String) -> (_ content: Serializible?) -> Response {
        return { requestType in
            return { resource in
                return { content in
                    return Response(id: id, requestType: requestType, resource: resource, content: content)
                }
            }
        }
    }
        
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Response> {
        return create <^>
            con.getValue(ResponseSerializer.idField) >>> cast <*>
            con.getValue(ResponseSerializer.requestTypeField) >>> cast <*>
            con.getValue(ResponseSerializer.resourceField) >>> cast <*>
            con.getOptionalObject(ResponseSerializer.contentField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext,_ obj: Response) -> Optional<Error> {
        return
            con.setValue(ResponseSerializer.idField, obj.id) <*>
            con.setValue(ResponseSerializer.requestTypeField, obj.requestType) <*>
            con.setValue(ResponseSerializer.resourceField, obj.resource) <*>
            con.setOptionalObject(ResponseSerializer.contentField, obj.content)
    }
}
