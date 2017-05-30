//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class StatusTests: XCTestCase {
    let service = SerializationService()

    override func setUp() {
        super.setUp()
        service.addSerializer(Status.self, StatusSerializer())
    }

    func testSerializationRoundTrip() {
        let status = Status.init(code: 1, message: "test")
        let deserializedStatus = service.roundTrip(status)

        XCTAssertEqual(status, deserializedStatus)
    }
    
}
