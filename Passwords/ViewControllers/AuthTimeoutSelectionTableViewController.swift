//
//  AuthTimeoutSelectionTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/13/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit
import PasswordServices

protocol AuthTimeoutSelectionDelegate {
    func timeoutWasSelected(withSeconds seconds: Int?)
}

class AuthTimeoutSelectionTableViewController: UITableViewControllerAuthenticable {
    
    var selectionDelegate: AuthTimeoutSelectionDelegate?
    var selection: Int?
    var dismissOnSelection = false
    
    let groupedSelections = [[0], [30, 60, 60*2, 60*3, 60*4, 60*5, 60*30, 60*60]]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let oldSelection = selection, let oldIndexPath = findIndexPath(ofFirstElement: oldSelection, in2DArray: groupedSelections), let oldCell = tableView.cellForRow(at: oldIndexPath) {
            oldCell.accessoryType = .none
        }
        
        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .checkmark
        
        selection = groupedSelections[indexPath.section][indexPath.row]
        selectionDelegate?.timeoutWasSelected(withSeconds: selection)
        
        if dismissOnSelection {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return groupedSelections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupedSelections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuthTimeoutSelectionCell", for: indexPath)
        
        if let selection = selection, selection == groupedSelections[indexPath.section][indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        var config = cell.defaultContentConfiguration()
        config.text = formatAuthTimeoutText(groupedSelections[indexPath.section][indexPath.row])
        cell.contentConfiguration = config

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
