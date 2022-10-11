//
//  PasswordService.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation
import UIKit

typealias AppRecordsMap = Dictionary<String, [Password]>

enum PasswordServiceError: Error {
    case deleteReferenceError(uuid: String)
    case updateReferenceError(uuid: String)
}

extension PasswordServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deleteReferenceError(let uuid):
            return NSLocalizedString("The record to delete with UUID \(uuid) does not exist.", comment: "")
        case .updateReferenceError(let uuid):
            return NSLocalizedString("The record to update with UUID \(uuid) does not exist.", comment: "")
        }
    }
}

protocol PasswordServiceProtocol {
    func getAppNames() -> [String]
    func reloadData() throws
    func getPasswordRecords() -> [Password]
    func getPasswordRecords(forApp app: String) -> [Password]?
    func createPasswordRecord(app: String, user: String, password: String) throws
    func deletePasswordRecord(_ record: Password) throws
    func updatePasswordRecord(_ record: Password) throws
    func hasUpdates() -> Bool
    func acknowledgeUpdates() -> Void
}

class PasswordService {
    // WARNING: Not tested for thread safety.
    
    static let `default` = PasswordService()
    let kDefaultsKey = "passwordRecords"
    
    private init() {
        try! loadPasswordRecords()
    }
    
    // MARK: - Private
    
    private let defaults = UserDefaults.standard
    
    private var appRecordsMap: AppRecordsMap {
        return Dictionary(grouping: passwordRecords, by: { $0.app })
    }
    
    private var passwordRecords = [Password]()
    
    private var hasUpdatesFlag = true
    
    private func loadPasswordRecords() throws {
        let savedData = defaults.object(forKey: kDefaultsKey) as! Data
        passwordRecords = try JSONDecoder().decode([Password].self, from: savedData)
        hasUpdatesFlag = true
        debugPrint("PasswordService loaded \(passwordRecords.count) password records.")
    }
    
    private func savePasswordRecords() throws {
        let encodedData = try JSONEncoder().encode(passwordRecords)
        defaults.set(encodedData, forKey: kDefaultsKey)
        hasUpdatesFlag = true
        debugPrint("PasswordService saved \(passwordRecords.count) password records.")
    }
    
}

// MARK: - PasswordServiceProtocol
extension PasswordService: PasswordServiceProtocol {
    
    func reloadData() throws {
        try loadPasswordRecords()
    }
    
    func getAppNames() -> [String] {
        return Array(appRecordsMap.keys)
    }
    
    func getPasswordRecords() -> [Password] {
        return passwordRecords
    }
    
    func getPasswordRecords(forApp app: String) -> [Password]? {
        return appRecordsMap[app]
    }
    
    func createPasswordRecord(app: String, user: String, password: String) throws {
        let passwordRecord = Password(app: app, user: user)
        try passwordRecord.setPassword(password)
        passwordRecords.append(passwordRecord)
        try savePasswordRecords()
        debugPrint("PasswordService added password record for \(app) \(user)")
    }
    
    //  TODO: These last two are O(N), but they could be O(1) if passwordRecords were cached against their uuid.
    
    func deletePasswordRecord(_ record: Password) throws {
        for (index, cur) in passwordRecords.enumerated() {
            if cur.uuid == record.uuid {
                passwordRecords.remove(at: index)
                try savePasswordRecords()
                debugPrint("PasswordService deleted password record \(record.uuid)")
                return
            }
        }
        throw PasswordServiceError.deleteReferenceError(uuid: record.uuid)
    }
    
    func updatePasswordRecord(_ record: Password) throws {
        for cur in passwordRecords {
            if cur.uuid == record.uuid {
                cur.app = record.app
                cur.user = record.user
                if let newPassword = record.getPassword() {
                    try cur.setPassword(newPassword)
                }
                try savePasswordRecords()
                debugPrint("PasswordService updated password record \(record.uuid)")
                return
            }
        }
        throw PasswordServiceError.updateReferenceError(uuid: record.uuid)
    }
    
    func hasUpdates() -> Bool {
        return hasUpdatesFlag
    }
    
    func acknowledgeUpdates() {
        hasUpdatesFlag = false
    }
}
