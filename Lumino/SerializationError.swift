//
//  SerializationError.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

enum SerializationError: Error {
    case serializerNotFound(type: Any.Type)
    case expectingType(key: String, type: Any.Type)
    case expectingKey(key: String)
}

