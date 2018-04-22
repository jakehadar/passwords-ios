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
    
    var passwordRecords = [PasswordRecord]() {
        didSet {
            savePasswordRecords()
            refreshAppsRecords()
        }
    }
    
    var appRecordsDict = Dictionary<String, [PasswordRecord]>()
    var apps = [String]()
    
    let defaults = UserDefaults.standard
    
    override init() {
        super.init()
        loadPasswordRecords()
    }
    
    func refreshAppsRecords() {
        var newAppRecordsDict = Dictionary<String, [PasswordRecord]>()
        var newApps = [String]()
        for record in passwordRecords {
            let app = record.app
            if newAppRecordsDict[app] == nil {
                newAppRecordsDict[app] = [record]
            } else {
                newAppRecordsDict[app]!.append(record)
            }
            if !newApps.contains(app) {
                newApps.append(app)
            }
        }
        appRecordsDict = newAppRecordsDict
        apps = newApps
    }
    
    // MARK: - PasswordRecord
    
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
    
    func deletePasswordRecord(app: String, user: String) {
        for (index, record) in passwordRecords.enumerated() {
            if record.app == app && record.user == user {
                passwordRecords.remove(at: index)
                print("Deleted password records for \(app) \(user)")
            }
        }
    }
    
    func deletePasswordRecord(uuid: String) {
        for (index, record) in passwordRecords.enumerated() {
            if record.uuid == uuid {
                passwordRecords.remove(at: index)
                print("Deleted password record \(uuid)")
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
    
}

extension PasswordRecordManager: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard apps.count > 0 else { return 0 }
        let app = apps[section]
        return appRecordsDict[app]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let app = apps[indexPath.section]
        let records = appRecordsDict[app]
        let record = records![indexPath.row]
        var cell = UITableViewCell()
        
        if let passwordRecordCell = tableView.dequeueReusableCell(withIdentifier: "PasswordRecordCell") {
            passwordRecordCell.textLabel?.text = record.user
            cell = passwordRecordCell
        }
        
        return cell
    }
}
