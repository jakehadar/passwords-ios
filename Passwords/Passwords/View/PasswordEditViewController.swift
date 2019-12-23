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

class PasswordEditViewController: UITableViewController {
    @IBOutlet weak var appTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var maskSwitch: UISwitch!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var commitButton: UIBarButtonItem!
        
    private let service = PasswordService.sharedInstance
    var passwordRecord: Password? {
        didSet {
            if passwordRecord == nil {
                editingMode = .create
            } else {
                editingMode = .modify
            }
        }
    }
    
    private var editingMode: PasswordEditingMode = .create
    private var editingCancelled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editingMode == .create {
            title = "New"
            commitButton.title = "Save"
            commitButton.style = .done
            
        } else {
            title = "Edit"
            commitButton.title = "Done"
            commitButton.style = .done
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        disableSaveButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.modalPresentationStyle = .fullScreen
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
    
    @objc func commit() {
        if validateInputs() {
            dismissAndReload()
        }
    }
    
    @objc func cancel() {
        editingCancelled = true
        dismissAndReload()
    }
    
    func dismissAndReload() {
        dismiss(animated: true) {
            if let parent = self.parent as? PasswordListViewController {
                parent.reloadData()
            }
        }
    }
    
    @objc func dismissKeyboard() {
        appTextField.resignFirstResponder()
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func enableSaveButton() {
        commitButton.isEnabled = true
    }
    
    func disableSaveButton() {
        commitButton.isEnabled = false
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
        if validateInputs() {
            enableSaveButton()
        } else {
            disableSaveButton()
        }
    }
    
    @IBAction func maskSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            passwordTextField.isSecureTextEntry = true
        } else {
            passwordTextField.isSecureTextEntry = false
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        cancel()
    }
    
    @IBAction func commitButtonTapped(_ sender: UIBarButtonItem) {
        commit()
    }
    
}

extension PasswordEditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
