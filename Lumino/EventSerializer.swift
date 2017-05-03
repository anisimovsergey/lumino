//
//  EventSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class EventSerializer : SerializerBase<Event> {
    static let eventTypeField: String = "eventType"
    static let resourceField: String = "resource"
    static let contentField: String = "content"
    
    func create(eventType: String) -> (_ resource: String) -> (_ content: Serializible?) -> Event {
        return { resource in
            return { content in
                return Event(eventType: eventType, resource: resource, content: content)
            }
        }
    }
    
    override var type: String {
        get {
            return "event"
        }
    }

    override func deserializeImpl(_ con: DeserializationContext) -> Result<Event> {
        return create <^>
            con.getValue(EventSerializer.eventTypeField) >>> cast <*>
            con.getValue(EventSerializer.resourceField) >>> cast <*>
            con.getOptionalObject(EventSerializer.contentField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext,_ obj: Event) -> Optional<Error> {
        return
            con.setValue(EventSerializer.eventTypeField, obj.eventType) <*>
            con.setValue(EventSerializer.resourceField, obj.resource) <*>
            con.setOptionalObject(EventSerializer.contentField, obj.content)
    }
}
