//
//  WebSocketAccess.swift
//  Lumino
//
//  Created by Sergey Anisimov on 01/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation
import Starscream

class WebSocketClient: WebSocketDelegate {
    private let readRequestType = "read"
    private let updateRequestType = "update"
    private let colorResource = "color"
    private let settingsResource = "settings"
    
    private let serializer: SerializationService
    private let socket: WebSocket!

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
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        switch serializer.deserializeFromString(text) {
        case let .Value(obj):
            switch obj {
            case let response as Response:
                processResponse(response)
            case let event as Event:
                processEvent(event)
            default:
                break
            }
        default:
            break;
        }
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }
    
    private func processResponse(_ response: Response) {
        
    }

    private func processEvent(_ event: Event) {
        
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
        let lastId = getRandomID()
        let request = Request(id: lastId, requestType: readRequestType, resource: colorResource)
        switch self.serializer.serializeToString(request) {
        case let .Value(json):
            socket.write(string: json)
            return .none
        case let .Error(error): return error
        }
    }
}
