//
//  Device.swift
//  Lumino
//
//  Created by Sergey Anisimov on 05/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class DeviceListItem {
    var color: Color?
    var name: String?
    let client: WebSocketClient!
    
    init(_ client: WebSocketClient) {
        self.client = client
    }
}

