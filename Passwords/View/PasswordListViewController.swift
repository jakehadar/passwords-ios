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
        
    var selectedRecord: Password?
    
    var appNames: [String] {
        return passwordService.getAppNames().map { $0.uppercased() }.sorted()
    }
    
    var recordsForApp: Dictionary<String, [Password]> {
        let result = Dictionary(grouping: passwordService.getPasswordRecords(), by: { $0.app.uppercased() })
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.toolbar.isHidden = true
        authController.authenticate()
        
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.toolbar.isHidden = false
    }
    
    func reloadData() {
        do {
            try passwordService.reloadData()
            tableView.reloadData()
        } catch {
            let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
            let app = appNames[indexPath.section]
            if let records = recordsForApp[app] {
                vc.passwordRecord = records[indexPath.row]
            }
        } else if let nc = segue.destination as? UINavigationController, let vc = nc.childViewControllers.first as? PasswordEditViewController {
            // Creating a new record
            vc.passwordRecord = nil
        }
    }
}

extension PasswordListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return appNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let appName = appNames[section]
        return recordsForApp[appName]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if appNames.count > 0 {
            let app = appNames[indexPath.section]
            if let records = recordsForApp[app] {
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
        return appNames[section]
    }
}

extension PasswordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PasswordDetail", sender: nil)
    }
}
