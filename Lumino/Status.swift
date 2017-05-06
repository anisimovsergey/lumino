//
//  Status.swift
//  Lumino
//
//  Created by Sergey Anisimov on 02/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

struct Status: Serializible {
    static let resourceId = "status"
    
    let code: Int
    let message: String
}
