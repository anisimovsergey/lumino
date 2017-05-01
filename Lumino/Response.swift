//
//  Response.swift
//  Lumino
//
//  Created by Sergey Anisimov on 27/03/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Response: Serializible {
    let id: String
    let requestType: String
    let resource: String
    let content: Serializible?
}

