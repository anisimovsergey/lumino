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
    private static let pingInterval = 3.0
    private static let pongTimeout = 2.0
    private static let disconnectTimeout = 1.0
    private static let responseTime = 0.2
    private static let coolingTime = 0.02

    private let readRequestType = "read"
    private let updateRequestType = "update"
    private let updatedEventType = "updated"

    private let serializer: SerializationService
    private let service: NetService!
    private var socket: WebSocket!
    private var pingTimer: Timer!
    private var pongTimer: Timer!
    private var commTimer: Timer!
    private var pendingRequests: Dictionary<RequestKey, Request> = [:]
    private var lastID: String? = nil
    private var pingCounter: uint = 0

    var connectionDelegate = MulticastDelegate<WebSocketConnectionDelegate>()
    var communicationDelegate = MulticastDelegate<WebSocketCommunicationDelegate>()

    var name: String {
        get {
            return service.name
        }
    }

    var isConnected: Bool {
        get {
            return socket != nil && socket.isConnected
        }
    }

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
        service.delegate = nil
        connect()
    }

    func disconnect() {
        print("disconnecting from service \(service.name) ...")
        socket.disconnect(forceTimeout: WebSocketClient.disconnectTimeout)
    }

    func requestColor() {
        print("requesting color from \(service.name) ...")
        self.sendRequest(requestType: readRequestType, resource: Color.resourceId, content: nil)
    }

    func updateColor(_ color: Color) {
        self.sendRequest(requestType: updateRequestType, resource: Color.resourceId, content: color)
    }

    func requestSettings() {
        print("requesting settings from \(service.name) ...")
        self.sendRequest(requestType: readRequestType, resource: Settings.resourceId, content: nil)
    }

    func updateSettings(_ settings: Settings) {
        self.sendRequest(requestType: updateRequestType, resource: Settings.resourceId, content: settings)
    }

    func websocketDidConnect(socket: WebSocket) {
        print("connected to service \(service.name)")
        clearPendingRequests()
        sendPing()
        connectionDelegate |> { delegate in
            delegate.websocketDidConnect(client: self)
        }
    }

    func clearPendingRequests() {
        self.lastID = nil
        self.pendingRequests.removeAll()
    }

    func sendPing() {
        print("send ping to service \(service.name)")
        self.socket.write(ping: Data())
        self.pongTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.pongTimeout, target: self, selector: #selector(self.noPong), userInfo: nil, repeats: false)
    }
    
    func noPong() {
        pingCounter += 1;
        if (pingCounter > 3) {
            disconnect()
        } else {
            sendPing()
        }
    }

    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        print("received pong from service \(service.name)")
        pingCounter = 0;
        self.pongTimer.invalidate()
        self.pingTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.pingInterval, target: self, selector: #selector(self.sendPing), userInfo: nil, repeats: false)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("disconnected from service \(service.name)")
        if self.pingTimer != nil {
            self.pingTimer.invalidate()
        }
        if self.pongTimer != nil {
            self.pongTimer.invalidate()
        }
        if self.commTimer != nil {
            self.commTimer.invalidate()
        }
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
        default: break
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data) {
    }

    private func processResponse(_ response: Response) {
        if self.lastID == response.id {
            self.commTimer.invalidate()
            self.commTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.coolingTime, target: self, selector: #selector(self.coolingEnd), userInfo: nil, repeats: false)
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

    private func sendRequest(requestType: String, resource: String, content: Serializible?) {
        let request = Request(id: getRandomID(), requestType: requestType, resource: resource, content: content)
        pendingRequests[RequestKey(requestType, resource)] = request
        sendFromPending();
    }
    
    private func sendFromPending() {
        if self.lastID == nil {
            if let request = pendingRequests.first {
                _ = sendRequest(request: request.value)
            }
        }
    }

    private func sendRequest(request: Request) {
        self.lastID = request.id
        switch self.serializer.serializeToString(request) {
        case let .Value(json):
            socket.write(string: json)
        case .Error:
            return
        }
        self.commTimer = Timer.scheduledTimer(timeInterval: WebSocketClient.responseTime, target: self, selector: #selector(self.noResponse), userInfo: nil, repeats: false)
    }
    
    func noResponse() {
        print("no response, resending...")
        self.lastID = nil
        sendFromPending()
    }
    
    func coolingEnd() {
        _ = pendingRequests.popFirst()
        self.lastID = nil
        sendFromPending()
    }
}
