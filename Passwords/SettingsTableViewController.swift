//
//  SettingsTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var authEnabledSwitch: UISwitch!
    @IBOutlet weak var authTimeoutLabel: UILabel!
    @IBOutlet weak var authTimeoutCell: UITableViewCell!
    @IBOutlet weak var infoCell1: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
        
        var config = infoCell1.defaultContentConfiguration()
        config.text = "Running on simulator"
        config.secondaryText = UIDevice.isSimulator ? "Yes" : "No"
        infoCell1.contentConfiguration = config
        
        authEnabledSwitch.isOn = UserDefaults.standard.bool(forKey: authController.kAuthEnabled)
        authTimeoutLabel.text = formatAuthTimeoutText(UserDefaults.standard.integer(forKey: authController.kAuthTimeout))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selection = tableView.cellForRow(at: indexPath)
        
        // Block destructive development features from running on real devices.
        // Arbitrary tag 99 used on storyboard to flag dangerous cells.
        if selection?.tag == 99 && !UIDevice.isSimulator {
            let ac = UIAlertController(title: "Disabled", message: "This action is only enabled on simulators to protect integrity of data on real devices during development.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
        
        switch selection?.reuseIdentifier {
        case "DeleteAllRecords":
            deleteAllRecords()
        case "InsertExampleRecords":
            insertExampleRecords()
        default:
            return
        }
    }
    
    func deleteAllRecords() {
        let ac = UIAlertController(title: "Warning", message: "This action will erase all passwords. This action cannot be undone.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Erase", style: .destructive) { [unowned self] _ in
            var deletedRecordCount = 0
            do {
                try passwordService.getPasswordRecords().forEach {
                    try passwordService.deletePasswordRecord($0)
                    deletedRecordCount += 1
                }
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
            let ac = UIAlertController(title: "Done", message: "Erased all \(deletedRecordCount) records.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        })
        self.present(ac, animated: true, completion: nil)
    }
    
    func insertExampleRecords() {
        let ac = UIAlertController(title: "Warning", message: "This action will insert dummy records for development testing.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Continue", style: .destructive) { [unowned self] _ in
            let dummyRecords = [
                ["Google", "account1@gmail.com", "password1"],
                ["Google", "account2@gmail.com", "password2"],
                ["Google", "account3@gmail.com", "password3"],
                ["Amazon", "user1", "password"],
                ["Facebook", "user1", "password"],
                ["Instagram", "user1@gmail.com", "password"],
                ["Instagram", "user2@gmail.com", "password"],
                ["Netflix", "user1@gmail.com", "password"],
                ["Github", "user1@gmail.com", "password"],
                ["Apple", "user1@icloud.com", "pass"]
            ]
            do {
                try dummyRecords.forEach { try passwordService.createPasswordRecord(app: $0[0], user: $0[1], password: $0[2]) }
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
            let ac = UIAlertController(title: "Done", message: "Inserted \(dummyRecords.count) dummy records.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true, completion: nil)
        })
        self.present(ac, animated: true, completion: nil)
    }

    // MARK: - Table view data source
    
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
     */

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AuthTimeoutSelectionTableViewController {
            vc.selectionDelegate = self
            vc.selection = UserDefaults.standard.integer(forKey: authController.kAuthTimeout)
            vc.dismissOnSelection = true
        }
    }
    
    // MARK: - Actions

    @IBAction func authEnabledSwitchToggled(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: authController.kAuthEnabled)
        if sender.isOn {
            authTimeoutCell.isUserInteractionEnabled = true
            authTimeoutCell.accessoryType = .disclosureIndicator
            authTimeoutLabel.text = formatAuthTimeoutText(UserDefaults.standard.integer(forKey: authController.kAuthTimeout))
        } else {
            authTimeoutCell.isUserInteractionEnabled = false
            authTimeoutCell.accessoryType = .none
            authTimeoutLabel.text = "Not Applicable"
        }
    }
}

extension SettingsTableViewController: AuthTimeoutSelectionDelegate {
    func timeoutWasSelected(withSeconds seconds: Int?) {
        let seconds = seconds ?? 0
        UserDefaults.standard.set(seconds, forKey: authController.kAuthTimeout)
        authTimeoutLabel.text = formatAuthTimeoutText(seconds)
    }
}
