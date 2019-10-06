//
//  PasswordEditViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

enum PasswordEditingMode {
    case create
    case modify
}

class PasswordEditViewController: UITableViewController, Storyboarded {
    @IBOutlet weak var appTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var maskSwitch: UISwitch!
    
    var coordinator: MainCoordinator!
    var service: PasswordServiceProtocol!
    var passwordRecord: Password? {
        didSet {
            if passwordRecord == nil {
                editingMode = .create
            } else {
                editingMode = .modify
            }
        }
    }
    
    var editingMode: PasswordEditingMode = .create
    var editingCancelled = false
    
    func configure(coordinator: MainCoordinator, service: PasswordServiceProtocol, record: Password?) {
        self.coordinator = coordinator
        self.service = service
        self.passwordRecord = record
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        disableSaveButton()
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
        appTextField.tag = 1
        userTextField.tag = 2
        passwordTextField.tag = 3
        
        switch editingMode {
        case .create:
            appTextField.returnKeyType = .next
            userTextField.returnKeyType = .next
            passwordTextField.returnKeyType = .done
            navigationController?.setToolbarHidden(true, animated: false)
            appTextField.becomeFirstResponder()
            
        case .modify:
            appTextField.text = passwordRecord!.app
            userTextField.text = passwordRecord!.user
            passwordTextField.text = passwordRecord!.getPassword()
            navigationController?.setToolbarHidden(false, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            appTextField.becomeFirstResponder()
        case 1:
            userTextField.becomeFirstResponder()
        case 2:
            passwordTextField.becomeFirstResponder()
        default:
            dismissKeyboard()
        }
    }
    
    func savePasswordRecord() {
        if validateInputs() {
            let app = appTextField.text!
            let user = userTextField.text!
            let password = "\(passwordTextField.text!)"
            
            switch editingMode {
            case .create:
                service.createPasswordRecord(app: app, user: user, password: password)
                
            case .modify:
                guard let record = passwordRecord else { fatalError() }
                record.app = app
                record.user = user
                record.setPassword(password)
                service.updatePasswordRecord(record)
            }
        }
    }
    
    func deletePasswordRecord() {
        guard editingMode == .modify else { return }
        
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            guard let record = self.passwordRecord else { fatalError() }
            
            self.service.deletePasswordRecord(record)
            self.passwordRecord = nil
            self.editingCancelled = true
            self.coordinator?.showPasswordList()
        }
        ac.addAction(deleteAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func validateInputs() -> Bool {
        // Check that text fields have text
        guard appTextField.text != nil else { return false }
        guard userTextField.text != nil else { return false }
        guard passwordTextField.text != nil else { return false }
        
        // Check that text fields have meaningful entries to save
        guard appTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        guard userTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        guard passwordTextField.text!.trimmingCharacters(in: .whitespaces) != "" else { return false }
        
        // In the case where an existing record is being edited, check that anything was actually modified
        if editingMode == .modify {
            let appUnchanged = appTextField.text == passwordRecord!.app
            let userUnchanged = userTextField.text == passwordRecord!.user
            let passwordUnchanged = passwordTextField.text == passwordRecord!.getPassword()
            
            if (appUnchanged && userUnchanged && passwordUnchanged) { return false }
        }
        
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
    
    @objc func dismissKeyboard() {
        appTextField.resignFirstResponder()
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func enableSaveButton() {
        if let saveButton = navigationItem.rightBarButtonItem {
            saveButton.isEnabled = true
        }
    }
    
    func disableSaveButton() {
        if let saveButton = navigationItem.rightBarButtonItem {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func textFieldPrimaryActionTriggered(_ sender: UITextField) {
        if editingMode == .create {
            switch sender.tag {
            case 1:
                sender.resignFirstResponder()
                userTextField.becomeFirstResponder()
            case 2:
                sender.resignFirstResponder()
                passwordTextField.becomeFirstResponder()
            default:
                passwordTextField.resignFirstResponder()
            }
        } else {
            sender.resignFirstResponder()
        }
    }
    
    
    @IBAction func textFieldValueDidChange(_ sender: UITextField) {
        if editingMode == .create {
            if validateInputs() {
                enableSaveButton()
            } else {
                disableSaveButton()
            }
        }
    }
    
    @IBAction func maskSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            passwordTextField.isSecureTextEntry = true
        } else {
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        deletePasswordRecord()
    }
}

extension PasswordEditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
