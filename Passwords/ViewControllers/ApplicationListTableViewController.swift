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

class ApplicationListTableViewController: UITableViewControllerAuthenticable {
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - User configuration
    
    // User selection can be sent directly to delegate.
    var selectionDelegate: ApplicationListSelectionDelegate?
    
    // This item will be selected when the list is presented. If the item does not exist, it will be created.
    var initialSelection: String?
    
    // Dismiss the view controller immediately after selecting a list item.
    var dismissOnSelection = false
    
    // MARK: - Internal state
    
    // The currently selected item.
    private var selection: String?
    
    // Data sources for list and search views.
    private var appNames = PasswordService.default.getAppNames().map { $0.trimmingCharacters(in: .whitespaces) }.sorted { $0.lowercased() < $1.lowercased() }
    private var filteredAppNames = [String]()
    
    // App names the user created during this presentation.
    private var newAppNames = [String]()
    
    // Hold an optional reference to the "Add" button on the new-application-alert-prompt, to facilitate enabling/disabling of this button based on input validation.
    private weak var createNewApplicationAlertAddAction: UIAlertAction?
    private weak var createNewApplicationAlertController: UIAlertController?
    private let kCreateNewApplicationAlertControllerDefaultMessage = "Enter application name"
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
        definesPresentationContext = true
        
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
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
        
        if let initialSelection = initialSelection {
            // When the initial selection is a new item, add it to the top of the list view and select it.
            if !collection(appNames, doesContain: initialSelection) {
                appNames.insert(initialSelection, at: 0)
                newAppNames.append(initialSelection)
                searchController.isActive ? updateSearchResults(for: searchController) : tableView.reloadData()
            }
            
            if let initialSelectionIndex = contextualApplicationNames(firstIndexOf: initialSelection) {
                // Don't dismiss the view when selecting initial item
                let originalDismissOnSelectionValue = dismissOnSelection
                dismissOnSelection = false
                
                // Select initial item
                let indexPath = IndexPath(row: initialSelectionIndex, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                
                // Restore dismiss-on-selection state
                dismissOnSelection = originalDismissOnSelectionValue
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        scrollToSelection()
    }
    
    // MARK: - Helpers
    
    func collection(_ collection: [String], doesContain string: String) -> Bool {
        return !collection.filter {
            $0.trimmingCharacters(in: .whitespaces).lowercased() == string.trimmingCharacters(in: .whitespaces).lowercased()
        }.isEmpty
    }
    
    func contextualApplicationNames(firstIndexOf selection: String) -> Int? {
        return searchController.isActive ? filteredAppNames.firstIndex(of: selection) : appNames.firstIndex(of: selection)
    }
    
    func contextualApplicationNames(itemAtIndex index: Int) -> String {
        return searchController.isActive ? filteredAppNames[index] : appNames[index]
    }
    
    func contextualApplicationNamesCount() -> Int {
        return searchController.isActive ? filteredAppNames.count : appNames.count
    }
    
    func scrollToSelection() {
        if let selection = selection, let selectionIndex = contextualApplicationNames(firstIndexOf: selection) {
            tableView.scrollToRow(at: IndexPath(row: selectionIndex, section: 0), at: .middle, animated: true)
        }
    }
    
    // MARK: - Table wiew
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // "Uncheck" the previously selected cell.
        if let prevSelection = selection, let prevSelectionIndex = contextualApplicationNames(firstIndexOf: prevSelection), let prevSelectedCell = tableView.cellForRow(at: IndexPath(row: prevSelectionIndex, section: 0)) {
            prevSelectedCell.accessoryType = .none
        }
        
        // "Check" the newly selected cell.
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        
        // Update selection state and notify delegate.
        let newSelection = contextualApplicationNames(itemAtIndex: indexPath.row)
        selection = newSelection
        selectionDelegate?.applicationWasSelected(withName: newSelection)
        if dismissOnSelection {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextualApplicationNamesCount()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicationCell", for: indexPath)
        let appName = contextualApplicationNames(itemAtIndex: indexPath.row)
        
        var content = cell.defaultContentConfiguration()
        content.text = appName
        content.secondaryText = collection(newAppNames, doesContain: appName) ? "(new)" : nil
        cell.contentConfiguration = content
        if let selection = selection, appName == selection {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

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
    
    // MARK: - Actions

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: "New Application", message: kCreateNewApplicationAlertControllerDefaultMessage, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.tag = TextFieldTags.addNewApplicationNameField.rawValue
            textField.autocorrectionType = .yes
            textField.autocapitalizationType = .words
            textField.clearButtonMode = .whileEditing
            textField.delegate = self
        }
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let addAction = UIAlertAction(title: "Add", style: .default) { [unowned self] _ in
            if let appName = ac.textFields?.first?.text?.trimmingCharacters(in: .whitespaces), appName != "", !self.collection(self.appNames, doesContain: appName) {
                
                // Insert the new app name into the local data sources.
                let indexPath = IndexPath(row: 0, section: 0)
                self.appNames.insert(appName, at: indexPath.row)
                self.newAppNames.append(appName)
                
                // Refresh the filtered data source (if necessary) and views.
                if self.searchController.isActive {
                    self.updateSearchResults(for: self.searchController)
                } else {
                    self.tableView.reloadData()
                }
                
                // Select and scroll to the new item.
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.tableView.delegate?.tableView?(self.tableView, didSelectRowAt: indexPath)
            } else {
                let ac = UIAlertController(title: "New Application", message: "Nothing was created", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
        ac.addAction(addAction)
        createNewApplicationAlertAddAction = addAction
        createNewApplicationAlertController = ac
        addAction.isEnabled = false
        present(ac, animated: true)
    }
    
    @IBAction func showSelectionTapped(_ sender: UIBarButtonItem) {
        scrollToSelection()
    }
}

extension ApplicationListTableViewController: UITextFieldDelegate {
    // A lot of extra work and complexity to disable the New Application alert prompt's "Add" button when no text is entered.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextFieldTags(rawValue: textField.tag) == .addNewApplicationNameField, let oldText = textField.text, let newRange = Range(range, in: oldText) {
            let newText = oldText.replacingCharacters(in: newRange, with: string).trimmingCharacters(in: .whitespaces).trimmingCharacters(in: .punctuationCharacters)
            let nameAlreadyExists = collection(appNames, doesContain: newText)
            let textIsValid = !newText.isEmpty && !nameAlreadyExists
            createNewApplicationAlertAddAction?.isEnabled = textIsValid
            createNewApplicationAlertController?.message = nameAlreadyExists ? "'\(newText)' already exists.\nEnter a unique name or cancel." : kCreateNewApplicationAlertControllerDefaultMessage
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

extension ApplicationListTableViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        // If a selection was made from the filtered list view, scroll to selection automatically when the search is cancelled.
        if let selection = selection, collection(filteredAppNames, doesContain: selection) {
            scrollToSelection()
        }
    }
}
