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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var maskSwitch: UISwitch!
    
    weak var coordinator: MainCoordinator?
    weak var passwordRecord: PasswordRecord?
    let recordManager = PasswordRecordManager.sharedInstance
    
    var editingCancelled = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editingCancelled = false
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !editingCancelled {
            savePasswordRecord()
        }
    }
    
    fileprivate func setupView() {
        if let passwordRecord = passwordRecord {
            if let password = passwordRecord.getPassword() {
                passwordTextField.text = password
            }
            appTextField.text = passwordRecord.app
            userTextField.text = passwordRecord.user
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
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
    
    func deletePasswordRecord() {
        if let record = passwordRecord {
            let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (action: UIAlertAction) in
                self.recordManager.deletePasswordRecord(record)
                self.passwordRecord = nil
                self.editingCancelled = true
                self.coordinator?.passwordList()
            }
            ac.addAction(deleteAction)
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
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
    
    @objc func save() {
        if validateInputs() {
            self.dismiss(animated: true)
        }
    }
    
    @objc func cancel() {
        editingCancelled = true
        self.dismiss(animated: true)
    }
    @IBAction func maskSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            passwordTextField.isSecureTextEntry = true
        } else {
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        deletePasswordRecord()
    }
}
