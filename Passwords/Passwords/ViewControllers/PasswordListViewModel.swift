//
//  PasswordListViewModel.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation
import UIKit

class PasswordListViewModel: NSObject {
    var coordinator: MainCoordinator
    var recordManager: PasswordRecordManager
    
    var apps = [String]()
    
    init(coordinator: MainCoordinator, recordManager: PasswordRecordManager) {
        self.coordinator = coordinator
        self.recordManager = recordManager
        
        super.init()
        reloadData()
    }
    
    func reloadData() {
        if let apps = recordManager.getApps() {
            self.apps = apps
            self.apps.sort()
        }
    }
    
    func addPassword() {
        coordinator.addPassword()
    }
    
    func editPassword(passwordRecord: PasswordRecord) {
        coordinator.editPassword(passwordRecord: passwordRecord)
    }
}

extension PasswordListViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard apps.count > 0 else { return 0 }
        return apps.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard apps.count > 0 else { return 0 }
        
        let app = apps[section]
        return recordManager.getPasswordRecordsCount(forApp: app)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        guard apps.count > 0 else { return cell }
        
        let app = apps[indexPath.section]
        if let records = recordManager.getPasswordRecords(forApp: app) {
            let record = records[indexPath.row]
            if let passwordRecordCell = tableView.dequeueReusableCell(withIdentifier: "PasswordRecordCell") {
                passwordRecordCell.textLabel?.text = record.user
                cell = passwordRecordCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard apps.count > 0 else { return "" }
        return apps[section]
    }
    
}

extension PasswordListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard apps.count > 0 else { return }
        
        let app = apps[indexPath.section]
        if let records = recordManager.getPasswordRecords(forApp: app) {
            let passwordRecord = records[indexPath.row]
            coordinator.showPassword(passwordRecord: passwordRecord)
        }
    }
}
