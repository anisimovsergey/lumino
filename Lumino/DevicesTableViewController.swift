//
//  DevicesTableViewController.swift
//  Lumino
//
//  Created by Sergey Anisimov on 19/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit
import MulticastDelegateSwift

class DevicesTableViewController: UITableViewController, NetServiceBrowserDelegate, WebSocketConnectionDelegate, WebSocketCommunicationDelegate {
    private var nsb: NetServiceBrowser!
    private var serializer: SerializationService!
    private var clients: Dictionary<WebSocketClient, DeviceListItem> = [:]
    private var devices = [DeviceListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        self.title = "Lumino"
        
        serializer = SerializationService()
        serializer.addSerializer(Color.self, ColorSerializer())
        serializer.addSerializer(Settings.self, SettingsSerializer())
        serializer.addSerializer(Request.self, RequestSerializer())
        serializer.addSerializer(Response.self, ResponseSerializer())
        serializer.addSerializer(Event.self, EventSerializer())
        serializer.addSerializer(Status.self, StatusSerializer())
        
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.start()
    }
    
    func start()  {
        print("listening for services...")
        self.devices.removeAll()
        self.nsb.searchForServices(ofType:"_lumino-ws._tcp", inDomain: "")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = devices[indexPath.row].name
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clients.count
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        let client = WebSocketClient(serializer, aNetService)
        self.clients[client] = DeviceListItem(client)
        client.connectionDelegate += self
        client.communicationDelegate += self
        client.connect()
    }
    
    func updateInterface() {
        self.tableView.reloadData()
    }
    
    func websocketDidConnect(client: WebSocketClient) {
        _ = client.requestColor()
        _ = client.requestSettings()
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        if let device = self.clients[client] {
            if let i = (self.devices.index{$0 === device}) {
                self.devices.remove(at: i)
                self.clients.removeValue(forKey: client)
            }
        }
    }
    
    func tryToAppend(_ device: DeviceListItem) {
        if (device.name != nil && device.color != nil) {
            self.devices.append(device)
            self.updateInterface()
        }
    }
    
    func websocketOnColorRead(client: WebSocketClient, color: Color) {
        let device = self.clients[client]!
        device.color = color
        tryToAppend(device)
    }
    
    func websocketOnColorUpdated(client: WebSocketClient, color: Color) {
        let device = self.clients[client]!
        device.color = color
        self.updateInterface()
    }
    
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings) {
        let device = self.clients[client]!
        device.name = settings.deviceName
        tryToAppend(device)
    }
    
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings) {
        let device = self.clients[client]!
        device.name = settings.deviceName
        self.updateInterface()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            if let nextViewController = segue.destination as? DeviceDetailsUIViewController {
                let row = self.tableView.indexPathForSelectedRow!.row
                nextViewController.device = self.devices[row]
            }
        }
    }
}
