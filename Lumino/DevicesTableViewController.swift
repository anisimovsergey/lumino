//
//  DevicesTableViewController.swift
//  Lumino
//
//  Created by Sergey Anisimov on 19/12/2016.
//  Copyright © 2016 Sergey Anisimov. All rights reserved.
//

import UIKit

class DevicesTableViewController: UITableViewController, NetServiceBrowserDelegate, NetServiceDelegate {
    var nsb : NetServiceBrowser!
    var discoveredServices = [NetService]()
    var resolvedServices = [NetService]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 75
        self.title = "Lumino"
        self.nsb = NetServiceBrowser()
        self.nsb.delegate = self
        self.start()
    }
    
    func start()  {
        print("listening for services...")
        self.discoveredServices.removeAll()
        self.resolvedServices.removeAll()
        self.nsb.searchForServices(ofType:"_lumino-ws._tcp", inDomain: "")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
        cell.textLabel?.text = resolvedServices[indexPath.row].name
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resolvedServices.count
    }
    
    func updateInterface() {
        for service in self.discoveredServices {
            if service.port == -1 {
                print("service \(service.name) of type \(service.type)" +
                    " not yet resolved")
                service.delegate = self
                service.resolve(withTimeout:10)
            } else {
                print("service \(service.name) of type \(service.type), " +
                    "host \(service.hostName!), port \(service.port)")
                resolvedServices.append(service)
            }
        }
        self.tableView.reloadData()
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        self.updateInterface()
    }
    
    func netServiceBrowserDidStopSearch(_ aNetServiceBrowser: NetServiceBrowser) {
         print("services search stopped")
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
        print("found service " + aNetService.name)
        self.discoveredServices.append(aNetService)
        if !moreComing {
            self.updateInterface()
        }
    }
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
        print("removing service")
        if let ix = self.discoveredServices.index(of:aNetService) {
            self.discoveredServices.remove(at:ix)
        }
        if let ix = self.resolvedServices.index(of:aNetService) {
            self.resolvedServices.remove(at:ix)
        }
        if !moreComing {
            self.updateInterface()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails"{
            if let nextViewController = segue.destination as? DeviceDetailsUIViewController {
                let row = self.tableView.indexPathForSelectedRow!.row
                nextViewController.service = resolvedServices[row]
            }
        }
    }
}
