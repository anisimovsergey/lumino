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
    private var nsbSearchTimer: Timer!

    private var serializer: SerializationService!
    private var clients: Dictionary<String, DeviceListItem> = [:]
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
        self.nsbSearchTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.restartSerach), userInfo: nil, repeats: true);
    }
    
    func start()  {
        print("listening for services...")
        self.clients.removeAll()
        self.devices.removeAll()
        restartSerach()
    }
    
    func restartSerach() {
        self.nsb.stop()
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
        return self.devices.count
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("discovered service \(service.name)")
        
        var deviceListItem = self.clients[service.name]
        if deviceListItem == nil {
            let client = WebSocketClient(serializer, service)
            client.connectionDelegate += self
            client.communicationDelegate += self
            deviceListItem = DeviceListItem(client)
            self.clients[client.name] = deviceListItem
        }
        if (!((deviceListItem?.client.isConnected)!)) {
            deviceListItem?.client.connect()
        }
    }
    
    func updateInterface() {
        self.tableView.reloadData()
    }
    
    func websocketDidConnect(client: WebSocketClient) {
        _ = client.requestColor()
        _ = client.requestSettings()
    }
    
    func websocketDidDisconnect(client: WebSocketClient) {
        if self.navigationController?.presentedViewController != self {
            return
        }
        if let device = self.clients[client.name] {
            if let i = (self.devices.index{$0 === device}) {
                self.devices.remove(at: i)
            }
            self.clients.removeValue(forKey: client.name)
        }
        self.updateInterface()
    }
    
    func tryToAdd(_ device: DeviceListItem) {
        if (device.name != nil && device.color != nil) {
            if (self.devices.index{$0 === device}) == nil {
                self.devices.append(device)
            }
            self.updateInterface()
        }
    }
    
    func websocketOnColorRead(client: WebSocketClient, color: Color) {
        let device = self.clients[client.name]!
        device.color = color
        tryToAdd(device)
    }
    
    func websocketOnColorUpdated(client: WebSocketClient, color: Color) {
        let device = self.clients[client.name]!
        device.color = color
        self.updateInterface()
    }
    
    func websocketOnSettingsRead(client: WebSocketClient, settings: Settings) {
        let device = self.clients[client.name]!
        device.name = settings.deviceName
        tryToAdd(device)
    }
    
    func websocketOnSettingsUpdated(client: WebSocketClient, settings: Settings) {
        let device = self.clients[client.name]!
        device.name = settings.deviceName
        self.updateInterface()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Removing the diconnected clients
        for (name, client) in self.clients {
            if !client.client.isConnected {
                if let i = (self.devices.index{$0 === client}) {
                    self.devices.remove(at: i)
                }
                self.clients.removeValue(forKey: name)
            }
        }
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
    
    @IBAction func unwindToDevices(_ segue:UIStoryboardSegue) {
        print("unwind to devices")
    }
}
