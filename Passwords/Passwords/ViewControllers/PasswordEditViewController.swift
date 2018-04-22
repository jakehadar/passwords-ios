//
//  PasswordEditViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordEditViewController: UIViewController, Storyboarded {
    @IBOutlet weak var appTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    weak var coordinator: MainCoordinator?
    weak var passwordRecord: PasswordRecord?
    let recordManager = PasswordRecordManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFields()
    }
    
    fileprivate func setTextFields() {
        if let passwordRecord = passwordRecord {
            if let password = passwordRecord.getPassword() {
                passwordTextField.text = password
            }
            appTextField.text = passwordRecord.app
            userTextField.text = passwordRecord.user
        }
    }
    
    func savePasswordRecord() {
        if validateInputs() {
            let app = appTextField.text!
            let user = userTextField.text!
            let password = passwordTextField.text!
            
            if let passwordRecord = passwordRecord {
                passwordRecord.app = app
                passwordRecord.user = user
                passwordRecord.setPassword(password)
                recordManager.savePasswordRecords()
            } else {
                recordManager.createPasswordRecord(app: app, user: user, password: password)
            }
        }
    }
    
    func validateInputs() -> Bool {
        guard appTextField.text != nil else { return false }
        guard userTextField.text != nil else { return false }
        guard passwordTextField.text != nil else { return false }
        
        guard appTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        guard userTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        guard passwordTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        
        return true
    }
    
    @objc func dismiss() {
        savePasswordRecord()
        self.dismiss(animated: true)
    }
}
