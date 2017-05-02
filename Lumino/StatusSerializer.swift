//
//  StatusSerialize.swift
//  Lumino
//
//  Created by Sergey Anisimov on 02/05/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

//
//  SettingsSerializer.swift
//  Lumino
//
//  Created by Sergey Anisimov on 30/04/2017.
//  Copyright © 2017 Sergey Anisimov. All rights reserved.
//

import Foundation

class StatusSerializer: SerializerBase<Status> {
    static let codeField: String = "code"
    static let messageField: String = "message"
    
    func create(statusCode: Int) -> (_ message: String) -> Status {
        return { message in
            return Status(statusCode: statusCode, message: message)
        }
    }
    
    override var type: String {
        get {
            return "status"
        }
    }
    
    override func deserializeImpl(_ con: DeserializationContext) -> Result<Status> {
        return create <^>
            con.getValue(StatusSerializer.codeField) >>> cast <*>
            con.getValue(StatusSerializer.messageField) >>> cast
    }
    
    override func serializeImpl(_ con: SerializationContext, _ obj: Status) -> Optional<Error> {
        return
            con.setValue(StatusSerializer.codeField, obj.statusCode) <*>
            con.setValue(StatusSerializer.messageField, obj.message)
    }
}
