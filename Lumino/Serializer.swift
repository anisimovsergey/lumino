//
//  Serializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 29/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

protocol Serializer {
    var type: String { get }
    
    func serialize(con: SerializationContext, obj: Serializible) -> Optional<Error>
    func deserialize(con: DeserializationContext) -> Result<Serializible>
}

class SerializerBase<T>: Serializer where T:Serializible {
    var type: String {
        get {
            preconditionFailure("This method must be overridden")
        }
    }

    func deserialize(con: DeserializationContext) -> Result<Serializible> {
        switch deserializeImpl(con) {
            case let .Value(val): return .Value(val as Serializible)
            case let .Error(error): return .Error(error)
        }
    }
    
    func deserializeImpl(_ con: DeserializationContext) -> Result<T> {
        preconditionFailure("This method must be overridden")
    }
    
    func serialize(con: SerializationContext, obj: Serializible) -> Optional<Error> {
        return serializeImpl(con, obj as! T)
    }

    func serializeImpl(_ con: SerializationContext, _ obj: T) -> Optional<Error> {
        preconditionFailure("This method must be overridden")
    }
}