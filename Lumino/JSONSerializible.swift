//
//  JSONSerializible.swift
//  Lumino
//
//  Created by Sergey Anisimov on 06/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

protocol JSONSerializible {
    func toJSONObj() -> Any
}
