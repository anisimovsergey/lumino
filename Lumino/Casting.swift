//
//  Casting.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

func cast<T>(a: Result<(key: String, value: JSON)>) -> Result<T> {
    switch a {
    case let .Value(key, value):
        if let v = value as? T {
            return .Value(v)
        } else {
            return .Error(SerializationError.expectingType(key: key, type: T.self))
        }
    case let .Error(error): return .Error(error)
    }
}

func cast(a: Result<(key: String, value: Serializible?)>) -> Result<Serializible?> {
    switch a {
    case let .Value(_, value):
        if let v = value {
            return .Value(v)
        } else {
            return .Value(nil)
        }
    case let .Error(error): return .Error(error)
    }
}
