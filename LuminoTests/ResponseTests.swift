//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class ResponseTests: XCTestCase {
    let color = Color.init(r: 1, g: 2, b: 3)
    let service = SerializationService()
    
    override func setUp() {
        super.setUp()
        service.addSerializer(Color.self, ColorSerializer())
        service.addSerializer(Response.self, ResponseSerializer())
    }
    
    func testSerializationRoundTripWithContent() {
        let response = Response.init(id: "id", requestType: "requestType", resource: "color", content: color)
        let deserializedResponse: Response = service.roundTrip(response)
        
        XCTAssertEqual(response, deserializedResponse)
        XCTAssertEqual(color, deserializedResponse.content as! Color)
    }
    
    func testSerializationRoundTripWithoutContent() {
        let response = Response.init(id: "id", requestType: "requestType", resource: "color", content: nil)
        let deserializedResponse: Response = service.roundTrip(response)
        
        XCTAssertEqual(response, deserializedResponse)
        XCTAssertNil(deserializedResponse.content)
    }
}
