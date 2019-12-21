//
//  PasswordDetailViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordDetailViewController: AuthenticableViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    
    weak var passwordRecord: Password?

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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? PasswordEditViewController {
            vc.passwordRecord = passwordRecord
        }
    }
    
    @IBAction func unmaskButtonHold(_ sender: UIButton) {
        if authenticated {
            passwordField.isSecureTextEntry = false
        } else {
            present(AuthenticationViewController(), animated: true)
        }
    }
    
    @IBAction func unmaskButtonRelease(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
}
