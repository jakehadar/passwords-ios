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
    case keychainWrapperGetError
    case keychainWrapperRemoveError
}

extension PasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .keychainWrapperSetError:
            return NSLocalizedString("KeychainWrapper unsuccessful update.", comment: "")
        case .keychainWrapperGetError:
            return NSLocalizedString("KeychainWrapper unsuccessful get.", comment: "")
        case .keychainWrapperRemoveError:
            return NSLocalizedString("KeychainWrapper unsuccessful remove.", comment: "")
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
        guard KeychainWrapper.standard.set(password, forKey: uuid) else { throw PasswordError.keychainWrapperSetError }
        touch()
        debugPrint("Password: set password for \(app) \(user)")
    }
    
    func removePassword() throws {
        if KeychainWrapper.standard.hasValue(forKey: uuid) {
            guard KeychainWrapper.standard.removeObject(forKey: uuid) else { throw PasswordError.keychainWrapperRemoveError }
        }
        debugPrint("Password: removed from keychain for key \(uuid)")
    }
    
    // MARK: - Misc
    
    func touch() {
        modified = DateHelper.toInt(Date())
        debugPrint("Password: modified \(app) \(user)")
    }
    
}
