//
//  SettingsTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var infoCell1: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        var config = infoCell1.defaultContentConfiguration()
        config.text = "Running on simulator"
        config.secondaryText = UIDevice.isSimulator ? "Yes" : "No"
        infoCell1.contentConfiguration = config
        
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
