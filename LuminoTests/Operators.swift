//
//  Operators.swift
//  Lumino
//
//  Created by Sergey Anisimov on 29/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

postfix operator >>*

postfix func >>*<A>(a: Result<A>) -> A? {
    switch a {
    case let .Value(value): return value
    case let .Error(error):
        XCTFail("Error: \(error)")
        return .none
    }
}
