//
//  Request.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Request: Serializible {
    let id: String
    let requestType: String
    let resource: String
    let content: Serializible?
}
