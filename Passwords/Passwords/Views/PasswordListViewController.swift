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
    
    var dataSource: PasswordListDataSource? {
        didSet {
            setupTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Applications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dataSource?.checkAuthentication()
        dataSource?.reloadData()
        tableView.reloadData()
        tableView.reloadSectionIndexTitles()
    }
    
    func setupTableView() {
        if let tableView = tableView {
            if let dataSource = dataSource {
                tableView.dataSource = dataSource
                tableView.delegate = dataSource
                tableView.reloadData()
            }
        }
    }
    
    @IBAction func addPassword(_ sender: UIBarButtonItem) {
        dataSource?.addPassword()
    }
}
