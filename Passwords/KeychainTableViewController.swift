//
//  KeychainTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/15/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class KeychainTableViewController: UITableViewController {
    
    var section0: [[String]] = [
        ["Service Name", KeychainWrapper.standard.serviceName],
        ["Access Group", KeychainWrapper.standard.accessGroup ?? ""]
    ]
    var section1 = [[String]]()
    
    let sectionTitles = ["Properties", "All Keys"]
    let reuseIdentifiers = ["KeychainInfoCell", "KeychainItemAccessibilityCell"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let keychainKeys = KeychainWrapper.standard.allKeys().reduce(into: [String]()) { $0.append($1) }
        var keyAccessibility = [String]()
        keychainKeys.forEach {
            if let value = KeychainWrapper.standard.accessibilityOfKey($0) {
                keyAccessibility.append(value.keychainAttrValue as String)
            } else {
                keyAccessibility.append("")
            }
        }
        for (i, keyName) in keychainKeys.enumerated() {
            section1.append([keyName, keyAccessibility[i]])
        }
        section0.append(["Key Count", "\(keychainKeys.count)"])
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return section0.count
        case 1:
            return section1.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifiers[indexPath.section], for: indexPath)

        var config = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case 0:
            config.text = section0[indexPath.row][0]
            config.secondaryText = section0[indexPath.row][1]
        case 1:
            config.text = section1[indexPath.row][0]
            config.secondaryText = section1[indexPath.row][1]
        default:
            break
        }
        
        cell.contentConfiguration = config

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    

}
