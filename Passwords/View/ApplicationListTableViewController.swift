//
//  ApplicationListTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/12/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

protocol ApplicationListSelectionDelegate {
    func applicationWasSelected(withName name: String?)
}

enum TextFieldTags: Int {
    case addNewApplicationNameField = 0
}

class ApplicationListTableViewController: UITableViewController {
    let searchController = UISearchController(searchResultsController: nil)
    
    var selectionDelegate: ApplicationListSelectionDelegate?
    var initialSelection: String?
    var selection: String?
    var dismissOnSelection = false
    
    var appNames = passwordService.getAppNames().map { $0.trimmingCharacters(in: .whitespaces) }.sorted { $0.lowercased() < $1.lowercased() }
    var filteredAppNames = [String]()
    
    weak var createNewApplicationAlertAddAction: UIAlertAction?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Applications"
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = true
        
        if let initialSelection = initialSelection {
            if !appNames.contains(where: { $0.trimmingCharacters(in: .whitespaces).range(of: initialSelection, options: .caseInsensitive) != nil }) {
                appNames.insert(initialSelection, at: 0)
                tableView.reloadData()
            }
            let indexPath = IndexPath(row: appNames.firstIndex(of: initialSelection)!, section: 0)
            let originalDismissOnSelectionValue = dismissOnSelection
            dismissOnSelection = false
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
            dismissOnSelection = originalDismissOnSelectionValue
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        if let prevSelection = selection, let prevSelectionIndex = searchController.isActive ? filteredAppNames.firstIndex(of: prevSelection) : appNames.firstIndex(of: prevSelection), let prevSelectionCell = tableView.cellForRow(at: IndexPath(row: prevSelectionIndex, section: 0)) {
            prevSelectionCell.accessoryType = .none
        }
        let newSelection = searchController.isActive ? filteredAppNames[indexPath.row] : appNames[indexPath.row]
        selection = newSelection
        selectionDelegate?.applicationWasSelected(withName: newSelection)
        if dismissOnSelection {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive ? filteredAppNames.count : appNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath)
        
        let appName = searchController.isActive ? filteredAppNames[indexPath.row] : appNames[indexPath.row]
        cell.textLabel?.text = appName
        if let selection = selection, appName == selection {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

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
    
    // MARK: - Actions

    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "New Application", message: "Enter application name", preferredStyle: .alert)
        ac.addTextField { textField in
            textField.tag = TextFieldTags.addNewApplicationNameField.rawValue
            textField.delegate = self
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            if let appName = ac.textFields?.first?.text, appName.trimmingCharacters(in: .whitespaces) != "", !self.appNames.contains(where: { $0.trimmingCharacters(in: .whitespaces).range(of: appName, options: .caseInsensitive) != nil }) {
                let indexPath = IndexPath(row: 0, section: 0)
                self.appNames.insert(appName, at: indexPath.row)
                if self.searchController.isActive {
                    self.updateSearchResults(for: self.searchController)
                } else {
                    self.tableView.reloadData()
                }
                
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: indexPath)
            } else {
                let ac = UIAlertController(title: "New Application", message: "Nothing created", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
        ac.addAction(addAction)
        createNewApplicationAlertAddAction = addAction
        addAction.isEnabled = false
        present(ac, animated: true)
    }
}

extension ApplicationListTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch TextFieldTags(rawValue: textField.tag) {
        case .addNewApplicationNameField:
            guard let oldText = textField.text else { break }
            let newText = oldText.replacingCharacters(in: Range(range, in: oldText)!, with: string)
            createNewApplicationAlertAddAction?.isEnabled = !newText.trimmingCharacters(in: .whitespaces).isEmpty
        default:
            break
        }
        return true
    }
}

extension ApplicationListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != "" {
            filteredAppNames = appNames.filter {
                $0.lowercased().range(of: searchController.searchBar.text?.lowercased() ?? "") != nil
            }
        } else {
            filteredAppNames = appNames
        }
        tableView.reloadData()
    }
}
