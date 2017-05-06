//
//  WebSocketAccess.swift
//  Lumino
//
//  Created by Sergey Anisimov on 01/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation
import Starscream
import MulticastDelegateSwift

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

protocol WebSocketConnectionDelegate: class {
    func websocketDidConnect(client: WebSocketClient)
    func websocketDidDisconnect(client: WebSocketClient)
}

protocol WebSocketCommunicationDelegate: class {
    func websocketOnColorRead(client: WebSocketClient, color: Color)
    func websocketOnColorUpdated(client: WebSocketClient, color: Color)
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings)
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings)
}

class WebSocketClient: NSObject, WebSocketDelegate, WebSocketPongDelegate, NetServiceDelegate {
    private static let pingInterval = 3.0 // 3 sec
    private static let pongTimeout = 3.0 // 3 sec
    
    private let readRequestType = "read"
    private let updateRequestType = "update"
    private let colorResource = "color"
    private let settingsResource = "settings"
    private let updatedEventType = "updated"
    
    private let serializer: SerializationService
    private let service: NetService!
    private var socket: WebSocket!
    private var pingTimer: Timer!
    private var pongTimer: Timer!
    private var pendingRequests: Dictionary<RequestKey, Request> = [:]
    private var lastID: String? = nil

    var connectionDelegate = MulticastDelegate<WebSocketConnectionDelegate>()
    var communicationDelegate = MulticastDelegate<WebSocketCommunicationDelegate>()
    
    init(_ serializer: SerializationService,_ service: NetService) {
        self.serializer = serializer
        self.service = service
    }
    
    func connect() {
        if service.port == -1 {
            print("resolving service \(service.name) ...")
            service.delegate = self
            service.resolve(withTimeout: 10)
        } else {
            print("connecting to service \(service.name) ...")
            self.socket = WebSocket(url: URL(string: "ws://\(service.hostName!)/ws")!)
            self.socket.delegate = self
            self.socket.pongDelegate = self
            socket.connect()
        }
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        connect()
    }
    
    func disconnect() {
        print("disconnecting from service \(service.name)")
        socket.disconnect()
    }
    
    func requestColor() -> Optional<Error> {
        print("requesting color from \(service.name) ...")
        return self.sendRequest(requestType: readRequestType, resource: colorResource, content: nil)
    }
    
    func updateColor(_ color: Color) -> Optional<Error> {
        return self.sendRequest(requestType: updateRequestType, resource: colorResource, content: color)
    }
    
    func requestSettings() -> Optional<Error> {
        print("requesting settings from \(service.name) ...")
        return self.sendRequest(requestType: readRequestType, resource: settingsResource, content: nil)
    }
    
    func updateSettings(_ settings: Settings) -> Optional<Error> {
        return self.sendRequest(requestType: updateRequestType, resource: settingsResource, content: settings)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("connected to service \(service.name)")
        sendPing()
        connectionDelegate |> { delegate in
            delegate.websocketDidConnect(client: self)
        }
    }
    
    func sendPing() {
        self.socket.write(ping: Data())
        self.pongTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.pongTimeout, target: self, selector: #selector(self.disconnect), userInfo: nil, repeats: false);
    }

    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        self.pongTimer.invalidate()
        self.pingTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.pingInterval, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: false);
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if self.pingTimer != nil {
            self.pingTimer.invalidate()
        }
        if self.pongTimer != nil {
            self.pongTimer.invalidate()
        }
        print("disconnected from service \(service.name)")
        connectionDelegate |> { delegate in
            delegate.websocketDidDisconnect(client: self)
        }
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
                print("received color from \(service.name)")
                communicationDelegate |> { delegate in
                    delegate.websocketOnColorRead(client: self, color: color)
                }
            case let settings as Settings:
                print("received settings from \(service.name)")
                communicationDelegate |> { delegate in
                    delegate.websocketOnSettingsRead(client: self, settings: settings)
                }
            default: break
            }
        }
    }

    private func processEvent(_ event: Event) {
        if event.eventType == updatedEventType {
            switch event.content {
            case let color as Color:
                communicationDelegate |> { delegate in
                    delegate.websocketOnColorUpdated(client: self, color: color)
                }
            case let settings as Settings:
                communicationDelegate |> { delegate in
                    delegate.websocketOnSettingsUpdated(client: self, settings: settings)
                }
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
