//
//  PasswordDetailViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordDetailViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    
    weak var coordinator: MainCoordinator?
    weak var passwordRecord: PasswordRecord?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let record = passwordRecord {
            title = record.app
            userLabel.text = record.user
            
            passwordField.isSecureTextEntry = true
            passwordField.text = record.getPassword()
            
            let dateModified = DateHelper.fromInt(record.modified)
            let unitsSinceLastModified = DateHelper.timeIntervalString(since: dateModified)
            lastModifiedLabel.text = "Last modified \(unitsSinceLastModified) ago"
        }
    }
    
    @objc func edit() {
        if let record = passwordRecord {
            coordinator?.editPassword(passwordRecord: record)
        }
    }
    
    @IBAction func unmaskButtonHold(_ sender: UIButton) {
        passwordField.isSecureTextEntry = false
    }
    
    @IBAction func unmaskButtonRelease(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
}