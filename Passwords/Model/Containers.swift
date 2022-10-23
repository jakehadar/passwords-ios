//
//  Containers.swift
//  Passwords
//
//  Created by James Hadar on 10/22/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import PasswordServices

class JSONExportContainer: NSObject, Codable {
    var passwords: [Password]
    var keychainEntries: [PasswordKeychainEntry]
    
    init(passwords: [Password], keychainEntries: [PasswordKeychainEntry]) {
        self.passwords = passwords
        self.keychainEntries = keychainEntries
    }
}

class PasswordKeychainEntry: NSObject, Codable {
    var uuid: String
    var text: String
    
    init(uuid: String, text: String) {
        self.uuid = uuid
        self.text = text
    }
}
