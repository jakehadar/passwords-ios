//
//  PasswordRecord.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation

class PasswordRecord: NSObject, Codable {
    
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
        if let password = KeychainWrapper.standard.string(forKey: uuid) {
            return password
        }
        
        print("No value in keychain matching \(uuid)")
        return nil
    }
    
    func setPassword(_ password: String) {
        if KeychainWrapper.standard.set(password, forKey: uuid) {
            print("Set password for \(app) \(user)")
            touch()
        }
    }
    
    // MARK: - Misc
    
    func touch() {
        modified = DateHelper.toInt(Date())
        print("Modified \(app) \(user)")
    }
    
}
