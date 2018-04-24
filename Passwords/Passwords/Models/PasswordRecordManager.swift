//
//  PasswordRecordManager.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation
import UIKit

class PasswordRecordManager: NSObject {
    static let sharedInstance = PasswordRecordManager()
    
    typealias AppRecordsMap = Dictionary<String, [PasswordRecord]>
    
    var passwordRecords = [PasswordRecord]() {
        didSet {
            savePasswordRecords()
            reloadAllData()
        }
    }
    
    var appRecordsMap = AppRecordsMap()
    var apps = [String]()
    
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        loadPasswordRecords()
    }
    
    func reloadAllData() {
        var newAppRecordsMap = AppRecordsMap()
        var newApps = [String]()
        for record in passwordRecords {
            let app = record.app
            if newAppRecordsMap[app] == nil {
                newAppRecordsMap[app] = [record]
            } else {
                newAppRecordsMap[app]!.append(record)
            }
            if !newApps.contains(app) {
                newApps.append(app)
            }
        }
        appRecordsMap = newAppRecordsMap
        apps = newApps
    }
    
    // MARK: - API
    
    func loadPasswordRecords() {
        if let savedData = defaults.object(forKey: "passwordRecords") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                passwordRecords = try jsonDecoder.decode([PasswordRecord].self, from: savedData)
                print("Loaded \(passwordRecords.count) password records")
            } catch {
                print("Failed to load password records.")
            }
        }
    }
    
    func savePasswordRecords() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(passwordRecords) {
            defaults.set(savedData, forKey: "passwordRecords")
            print("Saved \(passwordRecords.count) password records.")
        } else {
            print("Failed to save password records.")
        }
    }
    
    func deletePasswordRecord(_ record: PasswordRecord) {
        let uuidToDelete = record.uuid
        for (index, record) in passwordRecords.enumerated() {
            if record.uuid == uuidToDelete {
                passwordRecords.remove(at: index)
                print("Deleted password record \(uuidToDelete)")
                break
            }
        }
    }
    
    func createPasswordRecord(app: String, user: String, password: String) {
        let passwordRecord = PasswordRecord(app: app, user: user)
        passwordRecord.setPassword(password)
        passwordRecords.append(passwordRecord)
        print("Added password record for \(app) \(user)")
    }
    
    func getApps() -> [String]? {
        return Array(appRecordsMap.keys)
    }
    
    func getPasswordRecords(forApp app: String) -> [PasswordRecord]? {
        return appRecordsMap[app]
    }
    
    func getPasswordRecordsCount(forApp app: String) -> Int {
        if let count = appRecordsMap[app]?.count {
            return count
        }
        return 0
    }
    
}
