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
typealias UuidRecordMap = Dictionary<String, Password>

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
    func getRecords() -> [Password]
    func getRecords(forApp app: String) -> [Password]?
    func createRecord(app: String, user: String, password: String) throws
    func deleteRecord(_ record: Password) throws
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
    
    private var initialized = false
    
    private var records = [Password]()
    private var appRecordsMap: AppRecordsMap { return Dictionary(grouping: records, by: { $0.app }) }
    private var uuidRecordMap: UuidRecordMap { return records.reduce(into: UuidRecordMap()) { $0[$1.uuid] = $1 } }
    
    func migrate() throws {
        // Migrate passwords from UserDefaults to json document
        if let savedData = UserDefaults.standard.object(forKey: PasswordService.kDefaultsKey) as? Data {
            records = try JSONDecoder().decode([Password].self, from: savedData)
        }
        initialized = true
        try saveRecords()
        guard FileManager.default.fileExists(atPath: dataUrl.path) else { throw PasswordServiceError.migrationJsonDataFileNotFoundError }
        UserDefaults.standard.set(true, forKey: PasswordService.kMigratedToJson)
        debugPrint("PasswordService migrated from UserDefaults to Json")
    }
    
    private func loadRecords() throws {
        do {
            records = try JSONDecoder().decode([Password].self, from: Data(contentsOf: dataUrl))
        } catch {
            throw PasswordServiceError.readDataFromDocumentsError(error: error)
        }
        updatesDelegate?.dataHasChanged()
        debugPrint("PasswordService loaded \(records.count) password records.")
    }
    
    private func saveRecords() throws {
        // Failsafe to prevent passwords from being over-written with an empty list
        guard initialized else { throw PasswordServiceError.serviceUninitializedError }
        
        let encodedData = try JSONEncoder().encode(records)
        do {
            try encodedData.write(to: dataUrl)
        } catch {
            throw PasswordServiceError.writeDataToDocumentsError(error: error)
        }
        updatesDelegate?.dataHasChanged()
        debugPrint("PasswordService saved \(records.count) password records.")
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
            if !FileManager.default.fileExists(atPath: dataUrl.path) {
                try JSONEncoder().encode(records).write(to: dataUrl)
            }
            
            // Flag that UserDefaults migration does not need to happen
            UserDefaults.standard.set(true, forKey: PasswordService.kMigratedToJson)
            
            // Flag that the app's first time launch setup has finished
            UserDefaults.standard.set(true, forKey: PasswordService.kFirstLaunchSetupComplete)
        }
        try loadRecords()
        initialized = true
    }
    
    func getAppNames() -> [String] {
        return Array(appRecordsMap.keys)
    }
    
    func getRecords() -> [Password] {
        return records
    }
    
    func getRecords(forApp app: String) -> [Password]? {
        return appRecordsMap[app]
    }
    
    func createPasswordRecord(app: String, user: String, password: String, created: Int, modified: Int, uuid: String) throws {
        let record = Password(uuid: uuid, app: app, user: user, created: created, modified: modified)
        try record.setPassword(password)
        records.append(record)
        try saveRecords()
        debugPrint("PasswordService added password record \(record.uuid)")
    }
    
    func createRecord(app: String, user: String, password: String) throws {
        let record = Password(app: app, user: user)
        try record.setPassword(password)
        records.append(record)
        try saveRecords()
        debugPrint("PasswordService added password record \(record.uuid)")
    }
    
    func deleteRecord(_ reference: Password) throws {
        if let existing = uuidRecordMap[reference.uuid], let index = records.firstIndex(of: existing) {
            try existing.removePassword()
            records.remove(at: index)
            try saveRecords()
            debugPrint("PasswordService deleted password record \(reference.uuid)")
            return
        }
        throw PasswordServiceError.deleteReferenceError(uuid: reference.uuid)
    }
    
    func updatePasswordRecord(_ reference: Password) throws {
        if let existing = uuidRecordMap[reference.uuid] {
            existing.app = reference.app
            existing.user = reference.user
            if let updatedPassword = reference.getPassword() {
                try existing.setPassword(updatedPassword)
            }
            try saveRecords()
            debugPrint("PasswordService updated password record \(reference.uuid)")
            return
        }
        throw PasswordServiceError.updateReferenceError(uuid: reference.uuid)
    }
}
