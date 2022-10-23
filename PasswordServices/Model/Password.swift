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

public class Password: NSObject, Codable {
    
    public var uuid: String
    
    public var app: String {
        didSet {
            touch()
        }
    }
    
    public var domain: String? {
        didSet {
            touch()
        }
    }
    
    public var url: String? {
        didSet {
            touch()
        }
    }
    
    public var user: String {
        didSet {
            touch()
        }
    }
    
    public var created: Int
    public var modified: Int
    
    public convenience init(app: String, user: String) {
        let uuid = UUID().uuidString
        let created = DateHelper.toInt(Date())
        self.init(uuid: uuid, app: app, user: user, created: created, modified: created)
    }
    
    public convenience init(app: String, user: String, domain: String?, url: String?) {
        let uuid = UUID().uuidString
        let created = DateHelper.toInt(Date())
        self.init(uuid: uuid, app: app, user: user, created: created, modified: created, domain: domain, url: url)
    }
    
    public convenience init(uuid: String, app: String, user: String, created: Int, modified: Int) {
        self.init(uuid: uuid, app: app, user: user, created: created, modified: created, domain: nil, url: nil)
    }
    
    public init(uuid: String, app: String, user: String, created: Int, modified: Int, domain: String?, url: String?) {
        self.uuid = uuid
        self.app = app
        self.user = user
        self.domain = domain
        self.url = url
        self.created = created
        self.modified = modified
    }
    
    // MARK: - Keychain
    
    public func getPassword() -> String? {
        return sharedKeychain.string(forKey: uuid)
    }
    
    public func setPassword(_ password: String) throws {
        guard sharedKeychain.set(password, forKey: uuid) else { throw PasswordError.keychainWrapperSetError }
        touch()
        debugPrint("Password: set password for \(app) \(user)")
    }
    
    public func removePassword() throws {
        if sharedKeychain.hasValue(forKey: uuid) {
            guard sharedKeychain.removeObject(forKey: uuid) else { throw PasswordError.keychainWrapperRemoveError }
        }
        debugPrint("Password: removed from keychain for key \(uuid)")
    }
    
    // MARK: - Misc
    
    public func touch() {
        modified = DateHelper.toInt(Date())
        debugPrint("Password: modified \(app) \(user)")
    }
    
}
