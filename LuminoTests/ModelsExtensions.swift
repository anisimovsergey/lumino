//
//  Comparison.swift
//  Lumino
//
//  Created by Sergey Anisimov on 01/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

extension Color: Equatable {
    public static func == (lhs: Color, rhs: Color) -> Bool {
        return (lhs.r == rhs.r) &&
            (lhs.g == rhs.g) &&
            (lhs.b == rhs.b)
    }
}

extension Settings: Equatable {
    public static func == (lhs: Settings, rhs: Settings) -> Bool {
        return lhs.deviceName == rhs.deviceName
    }
}

extension Event: Equatable {
    public static func == (lhs: Event, rhs: Event) -> Bool {
        return (lhs.eventType == rhs.eventType) &&
            (lhs.resource == rhs.resource)
    }
}

extension Request: Equatable {
    public static func == (lhs: Request, rhs: Request) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.requestType == rhs.requestType) &&
            (lhs.resource == rhs.resource)
    }
}

extension Response: Equatable {
    public static func == (lhs: Response, rhs: Response) -> Bool {
        return (lhs.id == rhs.id) &&
            (lhs.requestType == rhs.requestType) &&
            (lhs.resource == rhs.resource)
    }
}
