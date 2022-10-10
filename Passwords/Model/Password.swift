//
//  Password.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation

enum PasswordError: Error {
    case keychainWrapperSetError
}

extension PasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .keychainWrapperSetError:
            return NSLocalizedString("KeychainWrapper unsuccessful update.", comment: "")
        }
    }
}

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

class Password: NSObject, Codable {
    
    var uuid: String
    
    var app: String {
        didSet {
            touch()
        }
    }
    
    var user: String {
        didSet {
            touch()
        }
    }
    
    var created: Int
    var modified: Int
    
    convenience init(app: String, user: String) {
        let uuid = UUID().uuidString
        let created = DateHelper.toInt(Date())
        self.init(uuid: uuid, app: app, user: user, created: created, modified: created)
    }
    
    init(uuid: String, app: String, user: String, created: Int, modified: Int) {
        self.uuid = uuid
        self.app = app
        self.user = user
        self.created = created
        self.modified = modified
    }
    
    // MARK: - Keychain
    
    func getPassword() -> String? {
        return KeychainWrapper.standard.string(forKey: uuid)
    }
    
    func setPassword(_ password: String) throws {
        if KeychainWrapper.standard.set(password, forKey: uuid) {
            debugPrint("Password: set password for \(app) \(user)")
            touch()
        } else {
            throw PasswordError.keychainWrapperSetError
        }
    }
    
    // MARK: - Misc
    
    func touch() {
        modified = DateHelper.toInt(Date())
        debugPrint("Password: modified \(app) \(user)")
    }
    
}
