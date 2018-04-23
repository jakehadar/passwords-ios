//
//  PasswordListViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordListViewController: UIViewController, Storyboarded {
    
    weak var viewModel: PasswordListViewModel?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Passwords"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordRecordCell")
        tableView.dataSource = viewModel
        tableView.delegate = viewModel
    }
    
    @IBAction func addPassword(_ sender: UIBarButtonItem) {
        viewModel?.addPassword()
    }
}
