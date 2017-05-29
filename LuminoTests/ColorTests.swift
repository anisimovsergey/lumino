//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class ColorTests: XCTestCase {
    let service = SerializationService()

    override func setUp() {
        super.setUp()
        service.addSerializer(Color.self, ColorSerializer())
    }

    func testSerializationRoundTrip() {
        let color = Color.init(h: 1, s: 2, v: 3)
        let deserializedColor = service.roundTrip(color)
        XCTAssertEqual(color, deserializedColor)
    }

}
