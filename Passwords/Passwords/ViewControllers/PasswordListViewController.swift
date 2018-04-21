//
//  PasswordListViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordListViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Passwords"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PasswordCell")
    }
    
    @IBAction func addPassword(_ sender: UIBarButtonItem) {
        
    }

}
