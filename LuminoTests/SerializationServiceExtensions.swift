//
//  Asserts.swift
//  Lumino
//
//  Created by Sergey Anisimov on 29/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

func GetValue<A, B>(_ result: Result<A>) -> B! {
    switch result {
    case let .Value(value): return value as! B
    case let .Error(err):
        XCTFail("Error: \(err)")
        return .none
    }
}

extension SerializationService {
    func roundTrip<T>(_ value: T) -> T! where T: Serializible {
        let serializationResult = self.serialize(value)
        let json: JSONDictionary = GetValue(serializationResult)
        let deserializationResult = self.deserialize(json)
        return GetValue(deserializationResult)
    }
}
