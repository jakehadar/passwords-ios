//
//  KeychainTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/15/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class KeychainTableViewController: UITableViewController {
    
    var section0 = [[String]]()
    var section1 = [[String]]()
    var section2 = [[String]]()
    
    let sectionTitles = ["Properties", "Active Keys", "Orphaned Keys"]
    let reuseIdentifiers = ["KeychainInfoCell", "KeychainItemCell", "KeychainItemCell"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        refreshData()
    }
    
    func refreshData() {
        section0 = [[String]]()
        section1 = [[String]]()
        section2 = [[String]]()
        
        var keychainKeys = [String]()
        if let allKeys = try? KeychainWrapper.standard.allKeys() {
            keychainKeys = allKeys.reduce(into: [String]()) { $0.append($1) }
        }
        let passwordUUIDs = Set(passwordService.getPasswordRecords().map { $0.uuid })
        var keyDetails = [String]()
        keychainKeys.forEach {
            keyDetails.append(passwordUUIDs.contains($0) ? "Active" : "Orphaned")
        }
        for (i, keyName) in keychainKeys.enumerated() {
            let status = keyDetails[i]
            if status == "Active" {
                section1.append([keyName, status])
            } else {
                section2.append([keyName, status])
            }
        }
        
        section0.append(["Service Name", KeychainWrapper.standard.serviceName])
        section0.append(["Access Group", KeychainWrapper.standard.accessGroup ?? ""])
        section0.append(["Key Count", "\(keychainKeys.count)"])
        section0.append(["Active Keys", "\(passwordUUIDs.count)"])
        section0.append(["Orphaned Keys", "\(keychainKeys.count - passwordUUIDs.count)"])
        
        tableView.reloadData()
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
        case 2:
            return section2.count
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
        case 2:
            config.text = section2[indexPath.row][0]
            config.secondaryText = section2[indexPath.row][1]
        default:
            break
        }
        
        cell.contentConfiguration = config

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    

    @IBAction func removeOrphanedKeysTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "Remove Orphaned Keys", message: "Delete \(section2.count) orphaned keychain entries?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Remove", style: .default) { [unowned self] _ in
            do {
                try getOrphanedKeychainKeys().forEach { KeychainWrapper.standard.removeObject(forKey: $0) }
                self.refreshData()
                presentInfo("Done", toViewController: self)
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
        })
        present(ac, animated: true)
    }
}
