//
//  SettingsTests.swift
//  Lumino
//
//  Created by Sergey Anisimov on 28/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import XCTest
@testable import Lumino

class EventTests: XCTestCase {
    let color = Color.init(r: 1, g: 2, b: 3)
    let service = SerializationService()
    
    override func setUp() {
        super.setUp()
        service.addSerializer(Color.self, ColorSerializer())
        service.addSerializer(Event.self, EventSerializer())
    }
    
    func testSerializationRoundTripWithContent() {
        let event = Event.init(eventType: "eventType", resource: "color", content: color)
        let deserializedEvent: Event = service.roundTrip(event)
        
        XCTAssertEqual(event, deserializedEvent)
        XCTAssertEqual(color, deserializedEvent.content as! Color)
    }
    
    func testSerializationRoundTripWithoutContent() {
        let event = Event.init(eventType: "eventType", resource: "color")
        let deserializedEvent: Event = service.roundTrip(event)
        
        XCTAssertEqual(event, deserializedEvent)
        XCTAssertNil(deserializedEvent.content)
    }
}
