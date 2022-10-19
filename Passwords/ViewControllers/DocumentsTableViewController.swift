//
//  DocumentsTableViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/14/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

protocol DocumentsListSelectionProtocol {
    func documentWasSelected(withUrl url: URL)
}

class DocumentsTableViewController: UITableViewControllerAuthenticable {
    var documents = [URL]()
    var selectionDelegate: DocumentsListSelectionProtocol?
    var dismissOnSelection = false
    
    private var isPresentedModally: Bool {
        return navigationController?.restorationIdentifier == "DocumentListNavigationController"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        if !isPresentedModally {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        refreshDocuments()
    }
    
    func refreshDocuments() {
        do {
            documents = try FileManager.default.contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        } catch {
            presentAlert(explaning: error, toViewController: self) { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func contextualDismiss() {
        if isPresentedModally {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectionDelegate?.documentWasSelected(withUrl: documents[indexPath.row])
        if dismissOnSelection {
            contextualDismiss()
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if documents.count == 0 {
            return "No documents found"
        }
        return nil
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return documents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentListCell", for: indexPath)

        let text = documents[indexPath.row].lastPathComponent
        if text == PasswordService.kStorageFilename {
            cell.textLabel?.textColor = .secondaryLabel
        }
        cell.textLabel?.text = text

        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if documents[indexPath.row].lastPathComponent == PasswordService.kStorageFilename {
            return false
        }
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                try FileManager.default.removeItem(at: documents[indexPath.row])
                refreshDocuments()
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
        }
    }
    

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DocumentViewerViewController, let indexPath = tableView.indexPathForSelectedRow {
            vc.url = documents[indexPath.row]
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !dismissOnSelection
    }
    
    // MARK: - Actions
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        contextualDismiss()
    }
}
