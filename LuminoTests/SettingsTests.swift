//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class SettingsTests: XCTestCase {
    let service = SerializationService()

    override func setUp() {
        super.setUp()
        service.addSerializer(Settings.self, SettingsSerializer())
    }

    func testSerializationRoundTrip() {
        let settings = Settings.init(isOn: true, uniqueName: "uniqueName", deviceName: "deviceName")
        let deserializedSettings = service.roundTrip(settings)
        XCTAssertEqual(settings, deserializedSettings)
    }

}
