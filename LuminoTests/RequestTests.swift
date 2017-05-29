//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class RequestTests: XCTestCase {
    let color = Color.init(h: 1, s: 2, v: 3)
    let service = SerializationService()

    override func setUp() {
        super.setUp()
        service.addSerializer(Color.self, ColorSerializer())
        service.addSerializer(Request.self, RequestSerializer())
    }

    func testSerializationRoundTripWithContent() {
        let request = Request.init(id: "id", requestType: "requestType", resource: "color", content: color)
        let deserializedRequest: Request = service.roundTrip(request)
        
        XCTAssertEqual(request, deserializedRequest)
        XCTAssertEqual(color, deserializedRequest.content as? Color)
    }

    func testSerializationRoundTripWithoutContent() {
        let request = Request.init(id: "id", requestType: "requestType", resource: "color")
        let deserializedRequest: Request = service.roundTrip(request)
        
        XCTAssertEqual(request, deserializedRequest)
        XCTAssertNil(deserializedRequest.content)
    }

}
