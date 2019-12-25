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
    
    var dataSource = PasswordListDataSource.default
    var controller: PasswordListDataControllerProtocol!
    
     var selectedRecord: Password?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller = dataSource.controller
        
        title = "Applications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
        
        tableView.dataSource = dataSource
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
        
        reloadData()
    }
    
    func reloadData() {
        dataSource.controller.reloadData()
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? PasswordDetailViewController, let indexPath = tableView.indexPathForSelectedRow {
            // Editing an existing record
            // TODO: make a controller.passwordRecordForIndexPath to own this logic
            let app = controller.appNames[indexPath.section]
            if let records = controller.recordsForApp[app] {
                vc.passwordRecord = records[indexPath.row]
            }
        } else if let nc = segue.destination as? UINavigationController, let vc = nc.childViewControllers.first as? PasswordEditViewController {
            // Creating a new record
            vc.passwordRecord = nil
        }
    }
}

extension PasswordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PasswordDetail", sender: nil)
    }
}
