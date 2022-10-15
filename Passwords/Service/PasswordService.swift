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
    case writeDataToDocumentsError(error: Error)
    case readDataFromDocumentsError(error: Error)
    case migrationJsonDataFileNotFoundError
    case serviceUninitializedError
}

extension PasswordServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deleteReferenceError(let uuid):
            return NSLocalizedString("The record to delete with UUID \(uuid) does not exist.", comment: "")
        case .updateReferenceError(let uuid):
            return NSLocalizedString("The record to update with UUID \(uuid) does not exist.", comment: "")
        case .serviceUninitializedError:
            return NSLocalizedString("The password service was called prior to initialization.", comment: "")
        case .writeDataToDocumentsError(error: let error):
            return NSLocalizedString("Error presisting data: \(error.localizedDescription)", comment: "")
        case .readDataFromDocumentsError(error: let error):
            return NSLocalizedString("Error reading data: \(error.localizedDescription)", comment: "")
        case .migrationJsonDataFileNotFoundError:
            return NSLocalizedString("Error migrating from UserDefaults storage to Json: data file not found", comment: "")
        }
    }
}

protocol PasswordServiceProtocol {
    func initialize() throws
    func getAppNames() -> [String]
    func getPasswordRecords() -> [Password]
    func getPasswordRecords(forApp app: String) -> [Password]?
    func createPasswordRecord(app: String, user: String, password: String) throws
    func deletePasswordRecord(_ record: Password) throws
}

protocol PasswordServiceUpdatesDelegate {
    func dataHasChanged() -> Void
}

class PasswordService {
    // WARNING: Not tested for thread safety.
    
    static let `default` = PasswordService()
    static let kDefaultsKey = "passwordRecords"
    static let kStorageFilename = "data.json"
    static let kMigratedToJson = "migratedFromUserDefaultsToJson"
    static let kFirstLaunchSetupComplete = "firstLaunchSetupComplete"
    
    var updatesDelegate: PasswordServiceUpdatesDelegate?
    
    // MARK: - Private
    
    private var dataUrl: URL {
        return getDocumentsDirectory().appendingPathComponent(PasswordService.kStorageFilename)
    }
    
    private let defaults = UserDefaults.standard
    private var initialized = false
    
    private var passwordRecords = [Password]()
    private var appRecordsMap: AppRecordsMap { return Dictionary(grouping: passwordRecords, by: { $0.app }) }
    
    func migrate() throws {
        // Migrate passwords from UserDefaults to json document
        if let savedData = UserDefaults.standard.object(forKey: PasswordService.kDefaultsKey) as? Data {
            passwordRecords = try JSONDecoder().decode([Password].self, from: savedData)
        }
        initialized = true
        try savePasswordRecords()
        guard FileManager.default.fileExists(atPath: dataUrl.path) else { throw PasswordServiceError.migrationJsonDataFileNotFoundError }
        UserDefaults.standard.set(true, forKey: PasswordService.kMigratedToJson)
        debugPrint("PasswordService migrated from UserDefaults to Json")
    }
    
    private func loadPasswordRecords() throws {
        do {
            passwordRecords = try JSONDecoder().decode([Password].self, from: Data(contentsOf: dataUrl))
        } catch {
            throw PasswordServiceError.readDataFromDocumentsError(error: error)
        }
        updatesDelegate?.dataHasChanged()
        debugPrint("PasswordService loaded \(passwordRecords.count) password records.")
    }
    
    private func savePasswordRecords() throws {
        // Failsafe to prevent passwords from being over-written with an empty list
        guard initialized else { throw PasswordServiceError.serviceUninitializedError }
        
        let encodedData = try JSONEncoder().encode(passwordRecords)
        do {
            try encodedData.write(to: dataUrl)
        } catch {
            throw PasswordServiceError.writeDataToDocumentsError(error: error)
        }
        updatesDelegate?.dataHasChanged()
        debugPrint("PasswordService saved \(passwordRecords.count) password records.")
    }
    
}

// MARK: - PasswordServiceProtocol
extension PasswordService: PasswordServiceProtocol {
    
    func initialize() throws {
        if UserDefaults.standard.bool(forKey: PasswordService.kFirstLaunchSetupComplete) {
            // App has already launched before and purportedly has data...
            
            // Check if UserDefaults migration needs to happen
            if !UserDefaults.standard.bool(forKey: PasswordService.kMigratedToJson) {
                try migrate()
            }
            
        } else {
            // App is running for the first time...
            
            // Create data.json file used to persist objects
            try JSONEncoder().encode(passwordRecords).write(to: dataUrl)
            
            // Flag that UserDefaults migration does not need to happen
            UserDefaults.standard.set(true, forKey: PasswordService.kMigratedToJson)
            
            // Flag that the app's first time launch setup has finished
            UserDefaults.standard.set(true, forKey: PasswordService.kFirstLaunchSetupComplete)
        }
        try loadPasswordRecords()
        initialized = true
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
}
