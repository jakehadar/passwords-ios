//
//  PasswordService.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation
import AuthenticationServices

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

public protocol PasswordServiceUpdatesDelegate {
    func dataHasChanged() -> Void
}

public class PasswordService {
    // Shared instance
    // WARNING: Not tested for thread safety.
    public static let `default` = PasswordService()
    
    // Key constants
    public static let kDefaultsKey = "passwordRecords"
    public static let kStorageFilename = "data.json"
    public static let kMigratedToJson = "migratedFromUserDefaultsToJson"
    public static let kFirstLaunchSetupComplete = "firstLaunchSetupComplete"
    
    // Configuration
    public var updatesDelegate: PasswordServiceUpdatesDelegate? {
        willSet {
            guard updatesDelegate == nil else { fatalError("There can be only one delegate for now until class is verified thread safe.") }
        }
    }
    public var credentialIdentityStore: ASCredentialIdentityStore? = ASCredentialIdentityStore.shared
    
    // Internal state
    private var initialized = false
    private var records = [Password]()
    
    // Helpers
    private var appRecordsMap: AppRecordsMap { return Dictionary(grouping: records, by: { $0.app }) }
    private var uuidRecordMap: UuidRecordMap { return records.reduce(into: UuidRecordMap()) { $0[$1.uuid] = $1 } }
    private var dataUrl: URL { return getDocumentsDirectory().appendingPathComponent(PasswordService.kStorageFilename) }
    
    func migrate() throws {
        // Migrate passwords from UserDefaults to json document
        if let savedData = UserDefaults.standard.object(forKey: PasswordService.kDefaultsKey) as? Data {
            records = try JSONDecoder().decode([Password].self, from: savedData)
        }
        initialized = true
        try saveRecords()
        guard FileManager.default.fileExists(atPath: dataUrl.path) else { throw PasswordServiceError.migrationJsonDataFileNotFoundError }
        sharedDefaults.set(true, forKey: PasswordService.kMigratedToJson)
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
    
    public func initialize() throws {
        if sharedDefaults.bool(forKey: PasswordService.kFirstLaunchSetupComplete) {
            // App has already launched before and purportedly has data...
            
            // Check if UserDefaults migration needs to happen
            if !sharedDefaults.bool(forKey: PasswordService.kMigratedToJson) {
                try migrate()
            }
            
        } else {
            // App is running for the first time...
            
            // Create data.json file used to persist objects
            if !FileManager.default.fileExists(atPath: dataUrl.path) {
                try JSONEncoder().encode(records).write(to: dataUrl)
            }
            
            // Flag that UserDefaults migration does not need to happen
            sharedDefaults.set(true, forKey: PasswordService.kMigratedToJson)
            
            // Flag that the app's first time launch setup has finished
            sharedDefaults.set(true, forKey: PasswordService.kFirstLaunchSetupComplete)
        }
        try loadRecords()
        initialized = true
    }
    
    public func getAppNames() -> [String] {
        return Array(appRecordsMap.keys)
    }
    
    public func getRecords() -> [Password] {
        return records
    }
    
    public func getRecords(forApp app: String) -> [Password]? {
        return appRecordsMap[app]
    }
    
    public func createPasswordRecord(app: String, user: String, password: String, created: Int, modified: Int, uuid: String, domain: String?, url: String?) throws {
        let record = Password(uuid: uuid, app: app, user: user, created: created, modified: modified, domain: domain, url: url)
        try record.setPassword(password)
        records.append(record)
        try saveRecords()
        debugPrint("PasswordService added password record \(record.uuid)")
    }
    
    public func createRecord(app: String, user: String, password: String, domain: String?, url: String?) throws {
        let record = Password(app: app, user: user, domain: domain, url: url)
        try record.setPassword(password)
        records.append(record)
        try saveRecords()
        debugPrint("PasswordService added password record \(record.uuid)")
    }
    
    public func createRecord(app: String, user: String, password: String) throws {
        let record = Password(app: app, user: user)
        try record.setPassword(password)
        records.append(record)
        try saveRecords()
        debugPrint("PasswordService added password record \(record.uuid)")
    }
    
    public func deleteRecord(_ reference: Password) throws {
        if let existing = uuidRecordMap[reference.uuid], let index = records.firstIndex(of: existing) {
            try existing.removePassword()
            records.remove(at: index)
            try saveRecords()
            debugPrint("PasswordService deleted password record \(reference.uuid)")
            return
        }
        throw PasswordServiceError.deleteReferenceError(uuid: reference.uuid)
    }
    
    public func updatePasswordRecord(_ reference: Password) throws {
        if let existing = uuidRecordMap[reference.uuid] {
            existing.app = reference.app
            existing.user = reference.user
            existing.domain = reference.domain
            existing.url = reference.url
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

extension PasswordService {
    func shouldReplaceCredentialIdentities() -> Bool {
        var decision = false
        credentialIdentityStore?.getState { state in
            if state.isEnabled && !state.supportsIncrementalUpdates {
                decision = true
            }
        }
        return decision
    }
    
    func replaceCredentialIdentities() {
        guard shouldReplaceCredentialIdentities() else { return }
        let identities = records.reduce(into: [ASPasswordCredentialIdentity]()) { result, element in
            let serviceIdentifier: ASCredentialServiceIdentifier? = {
                if let identifier = element.domain {
                    return ASCredentialServiceIdentifier(identifier: identifier, type: .domain)
                } else if let identifier = element.url {
                    return ASCredentialServiceIdentifier(identifier: identifier, type: .URL)
                } else {
                    return nil
                }
            }()
            
            if let serviceIdentifier = serviceIdentifier {
                result.append(ASPasswordCredentialIdentity(serviceIdentifier: serviceIdentifier, user: element.user, recordIdentifier: element.uuid))
            }
        }
        credentialIdentityStore?.replaceCredentialIdentities(with: identities)
    }
}
