//
//  PasswordListDataSource.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import Foundation
import UIKit

class PasswordListDataSource: NSObject, UITableViewDataSource {
    var controller: PasswordListDataControllerProtocol!
    
    init(controller: PasswordListDataControllerProtocol) {
        self.controller = controller
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return controller.appNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appName = controller.appNames[section]
        return controller.recordsForApp[appName]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        let apps = controller.appNames
        if apps.count > 0 {
            let app = apps[indexPath.section]
            if let records = controller.recordsForApp[app] {
                let record = records[indexPath.row]
                if let passwordRecordCell = tableView.dequeueReusableCell(withIdentifier: "PasswordRecordCell") {
                    passwordRecordCell.textLabel?.text = record.user
                    cell = passwordRecordCell
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return controller.appNames[section]
    }
}
