//
//  SerializationContext.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class SerializationContext {
    var json: JSONDictionary = [:]
    var service: SerializationService
    
    init(_ service: SerializationService) {
        self.service = service
    }
    
    private func serializeOptionalObject(_ key:String, _ val: Serializible) -> Optional<Error> {
        if let serializer = service.getSerializer(type(of: val)) {
            let context = SerializationContext(service)
            if let result = context.setValue(SerializationService.typeField, serializer.type) {
                return result
            }
            if let result = serializer.serialize(con: context, obj: val) {
                return result
            }
            json[key] = context.json as JSON?
            return .none
        } else {
            return SerializationError.serializerNotFound(type: type(of: val))
        }
    }
    
    func setOptionalObject(_ key: String,_ value: Serializible?) -> Optional<Error> {
        if let val = value {
            return serializeOptionalObject(key, val)
        } else {
            return .none
        }
    }
    
    func setValue(_ key: String,_ value: Any) -> Optional<Error> {
        json[key] = value as JSON?
        return .none
    }
}
