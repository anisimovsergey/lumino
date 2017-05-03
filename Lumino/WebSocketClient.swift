//
//  WebSocketAccess.swift
//  Lumino
//
//  Created by Sergey Anisimov on 01/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation
import Starscream

struct RequestKey : Hashable {
    private let requestType: String
    private let resource: String
    
    init(_ requestType: String,_ resource: String) {
        self.requestType = requestType
        self.resource = resource
    }
    
    static func ==(lhs: RequestKey, rhs: RequestKey) -> Bool {
        return lhs.requestType == rhs.requestType && lhs.resource == rhs.resource
    }
    
    var hashValue: Int {
        return requestType.hashValue ^ resource.hashValue
    }
}

protocol WebSocketClientDelegate: class {
    func websocketDidConnect()
    func websocketDidDisconnect()
    func websocketOnColorRead(color: Color)
    func websocketOnColorUpdated(color: Color)
    func websocketOnSettingsRead(settings: Settings)
    func websocketOnSettingsUpdated(settings: Settings)
}

class WebSocketClient: WebSocketDelegate {
    private let readRequestType = "read"
    private let updateRequestType = "update"
    private let colorResource = "color"
    private let settingsResource = "settings"
    private let updatedEventType = "updated"
    
    private let serializer: SerializationService
    private let socket: WebSocket!
    private var pendingRequests: Dictionary<RequestKey, Request> = [:]
    private var lastID: String? = nil

    public weak var delegate: WebSocketClientDelegate?
    
    init(_ serializer: SerializationService,_ service: NetService) {
        self.serializer = serializer
        self.socket = WebSocket(url: URL(string: "ws://\(service.hostName!)/ws")!)
        self.socket.delegate = self
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func requestColor() -> Optional<Error> {
        return self.sendRequest(requestType: readRequestType, resource: colorResource, content: nil)
    }
    
    func updateColor(_ color: Color) -> Optional<Error> {
        return self.sendRequest(requestType: updateRequestType, resource: colorResource, content: color)
    }
    
    func requestSettings() -> Optional<Error> {
        return self.sendRequest(requestType: readRequestType, resource: settingsResource, content: nil)
    }
    
    func updateSettings(_ settings: Settings) -> Optional<Error> {
        return self.sendRequest(requestType: updateRequestType, resource: settingsResource, content: settings)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        self.delegate?.websocketDidConnect()
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        self.delegate?.websocketDidDisconnect()
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        switch serializer.deserializeFromString(text) {
        case let .Value(obj):
            switch obj {
            case let response as Response:
                processResponse(response)
            case let event as Event:
                processEvent(event)
            default: break
            }
        default: break;
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    private func processResponse(_ response: Response) {
        if self.lastID == response.id {
            if let request = pendingRequests.popFirst() {
                _ = sendRequest(request: request.value)
            } else {
                self.lastID = nil
            }
        }
        if response.requestType == readRequestType {
            switch response.content {
            case let color as Color:
                delegate?.websocketOnColorRead(color: color)
            case let settings as Settings:
                delegate?.websocketOnSettingsRead(settings: settings)
            default: break
            }
        }
    }

    private func processEvent(_ event: Event) {
        if event.eventType == updatedEventType {
            switch event.content {
            case let color as Color:
                delegate?.websocketOnColorUpdated(color: color)
            case let settings as Settings:
                delegate?.websocketOnSettingsUpdated(settings: settings)
            default: break
            }
        }
    }

    private func getRandomID() -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        
        for _ in 0 ..< 6 {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    private func sendRequest(requestType: String, resource: String, content: Serializible?) -> Optional<Error> {
        let lastID = getRandomID()
        let request = Request(id: lastID, requestType: requestType, resource: resource, content: content)
        if self.lastID != nil {
            pendingRequests[RequestKey(requestType, resource)] = request
            return .none
        } else {
            return sendRequest(request: request)
        }
    }
    
    private func sendRequest(request: Request) -> Optional<Error> {
        self.lastID = request.id
        switch self.serializer.serializeToString(request) {
        case let .Value(json):
            socket.write(string: json)
            return .none
        case let .Error(error): return error
        }
    }
    
}
