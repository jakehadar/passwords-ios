//
//  PasswordListViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
        
    var selectedRecord: Password?
    
    var appNames: [String] {
        return passwordService.getAppNames().map { $0.uppercased() }.sorted()
    }
    
    var recordsForApp: Dictionary<String, [Password]> {
        let result = Dictionary(grouping: passwordService.getPasswordRecords(), by: { $0.app.uppercased() })
        return result
    }
    
    // For searching
    var filteredAppNames = [String]()
    var filteredRecordsForApp = Dictionary<String, [Password]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search Applications"
        searchController.searchBar.sizeToFit()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        title = "Applications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
        
        navigationController?.toolbar.isHidden = true
        // TODO: only reload data if the password service indicates the data has changed
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.toolbar.isHidden = false
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func reloadData() {
        do {
            try passwordService.reloadData()
            tableView.reloadData()
        } catch {
            presentAlert(explaning: error, toViewController: self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? PasswordDetailViewController, let indexPath = tableView.indexPathForSelectedRow {
            // Editing an existing record
            // TODO: make a controller.passwordRecordForIndexPath to own this logic
            if searchController.isActive {
                vc.passwordRecord = filteredRecordsForApp[filteredAppNames[indexPath.section]]?[indexPath.row]
            } else {
                vc.passwordRecord = recordsForApp[appNames[indexPath.section]]?[indexPath.row]
            }
            
        } else if let nc = segue.destination as? UINavigationController, let vc = nc.childViewControllers.first as? PasswordEditViewController {
            // Creating a new record
            vc.passwordRecord = nil
        }
    }
}

extension PasswordListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchController.isActive ? filteredAppNames.count : appNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return filteredRecordsForApp[filteredAppNames[section]]!.count
        } else {
            return recordsForApp[appNames[section]]!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "PasswordRecordCell") ?? UITableViewCell()
        // TODO: clean up this mostly repeated logic
        if searchController.isActive {
            let app = filteredAppNames[indexPath.section]
            let records = filteredRecordsForApp[app]
            let record = records![indexPath.row]
            cell.textLabel?.text = record.user
        } else {
            let app = appNames[indexPath.section]
            let records = recordsForApp[app]
            let record = records![indexPath.row]
            cell.textLabel?.text = record.user
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchController.isActive ? filteredAppNames[section] : appNames[section]
    }
}

extension PasswordListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != "" {
            filteredAppNames = appNames.filter {
                $0.lowercased().range(of: searchController.searchBar.text?.lowercased() ?? "") != nil
            }
            filteredRecordsForApp = recordsForApp.filter {
                $0.key.lowercased().range(of: searchController.searchBar.text?.lowercased() ?? "") != nil
            }
        } else {
            // If there's no text in the search bar, show all results
            filteredAppNames = appNames
            filteredRecordsForApp = recordsForApp
        }
        tableView.reloadData()
    }
}

extension PasswordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PasswordDetail", sender: nil)
    }
}
