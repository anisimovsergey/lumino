//
//  DeserializationContext.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class DeserializationContext {
    var json: JSONDictionary
    var service: SerializationService
    
    init(_ service: SerializationService,_ json: JSONDictionary) {
        self.service = service
        self.json = json
    }

    private func deserializeOptionalObject(_ key:String, _ dic: JSONDictionary) -> Result<(key: String, value: Serializible?)> {
        if let type = dic[SerializationService.typeField] as? String {
            if let serializer = service.getSerializer(type) {
                let context = DeserializationContext(service, dic)
                switch serializer.deserialize(con: context) {
                    case let .Value(value): return .Value(key: key, value: Optional(value))
                    case let .Error(error): return .Error(error)
                }
            } else {
                return .Error(SerializationError.serializerNotFound(type: type(of: type)))
            }
        } else {
            return .Error(SerializationError.expectingValueOfType(key: SerializationService.typeField, type: String.self))
        }
    }

    func getOptionalObject(_ key: String) -> Result<(key: String, value: Serializible?)> {
        if let value = self.json[key] {
            if let dic = value as? JSONDictionary {
                return deserializeOptionalObject(key, dic)
            } else {
                return .Error(SerializationError.expectingValueOfType(key: key, type: JSONDictionary.self))
            }
        } else {
            return .Value(key: key, value: nil)
        }
    }

    func getValue(_ key: String) -> Result<(key: String, value: JSON)> {
        if let value = self.json[key] {
            return .Value(key: key, value: value as JSON)
        } else {
            return .Error(SerializationError.expectingKey(key: key))
        }
    }
}
