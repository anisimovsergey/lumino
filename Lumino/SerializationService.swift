//
//  SerializationService.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Metatype : Hashable {
    private let base: ObjectIdentifier
    
    init(_ type: Any.Type) {
        base = ObjectIdentifier(type)
    }
    
    static func ==(lhs: Metatype, rhs: Metatype) -> Bool {
        return lhs.base == rhs.base
    }
    
    var hashValue: Int {
        return base.hashValue
    }
}

class SerializationService {
    static let typeField = "_type"
    private var serializersBySwiftType: Dictionary<Metatype, Serializer> = [:]
    private var serializersByJSONType: Dictionary<String, Serializer> = [:]
    
    func addSerializer(_ type: Any.Type, _ serializer: Serializer) {
        serializersBySwiftType[Metatype(type)] = serializer
        serializersByJSONType[serializer.type] = serializer
    }

    func getSerializer(_ type: Any.Type) -> Serializer? {
        return serializersBySwiftType[Metatype(type)]
    }

    func getSerializer(_ type: String) -> Serializer? {
        return serializersByJSONType[type]
    }

    func serialize(_ value: Serializible) -> Result<JSONDictionary> {
        if let serializer = getSerializer(type(of: value)) {
            let context = SerializationContext(self)
            if let result = context.setValue(SerializationService.typeField, serializer.type) {
                return .Error(result)
            }
            if let result = serializer.serialize(con: context, obj: value) {
                return .Error(result)
            }
            return .Value(context.json)
        } else {
            return .Error(SerializationError.serializerNotFound(type: type(of: value)))
        }
    }
    
    func deserialize(_ json: JSONDictionary) -> Result<Serializible> {
        if let type = json[SerializationService.typeField] as? String {
            if let serializer = getSerializer(type) {
                let context = DeserializationContext(self, json)
                return serializer.deserialize(con: context)
            } else {
                return .Error(SerializationError.serializerNotFound(type: type(of: type)))
            }
        } else {
            return .Error(SerializationError.expectingType(key: SerializationService.typeField, type: String.self))
        }
    }
}
