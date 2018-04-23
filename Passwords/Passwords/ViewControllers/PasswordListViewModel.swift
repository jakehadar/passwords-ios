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
    
    var apps: [String]?
    
    weak var vc: PasswordListViewController?
    
    init(coordinator: MainCoordinator, recordManager: PasswordRecordManager, vc: PasswordListViewController) {
        self.coordinator = coordinator
        self.recordManager = recordManager
        self.vc = vc
        
        apps = recordManager.getApps()
        super.init()
    }
    
    func addPassword() {
        coordinator.addPassword()
    }
    
    func editPassword(passwordRecord: PasswordRecord) {
        coordinator.editPassword(passwordRecord: passwordRecord)
    }
}

extension PasswordListViewModel: PasswordRecordManagerDelegate {
    func passwordRecordManagerDidUpdate() {
        apps = recordManager.getApps()
        vc?.tableView.reloadData()
    }
}

extension PasswordListViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let apps = apps {
            let app = apps[section]
            return recordManager.getPasswordRecordsCount(forApp: app)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let apps = apps {
            let app = apps[indexPath.section]
            if let records = recordManager.getPasswordRecords(forApp: app) {
                let record = records[indexPath.row]
                if let passwordRecordCell = tableView.dequeueReusableCell(withIdentifier: "PasswordRecordCell") {
                    passwordRecordCell.textLabel?.text = record.user
                    cell = passwordRecordCell
                }
            }
        }
        return cell
    }
}

extension PasswordListViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let apps = apps {
            let app = apps[indexPath.section]
            if let records = recordManager.getPasswordRecords(forApp: app) {
                let passwordRecord = records[indexPath.row]
                editPassword(passwordRecord: passwordRecord)
            }
        }
    }
}
