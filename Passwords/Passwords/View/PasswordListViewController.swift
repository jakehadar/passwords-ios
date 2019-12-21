//
//  PasswordListViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordListViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableView: UITableView!
    
    let passwordService = PasswordService.sharedInstance
    var controller: PasswordListDataControllerProtocol!
    var dataSource: UITableViewDataSource!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.controller = PasswordListDataController(service: passwordService)
        self.dataSource = PasswordListDataSource(controller: controller)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        controller.reloadData()
        tableView.reloadData()
    }
}

extension PasswordListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = controller.appNames[indexPath.section]
        if let records = controller.recordsForApp[app] {
            let record = records[indexPath.row]
            coordinator.showPasswordDetail(passwordRecord: record)
        }
    }
}
