//
//  PasswordEditViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

enum PasswordEditError: Error {
    case inputValidationAbortedCommitError
}

extension PasswordEditError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .inputValidationAbortedCommitError:
            return NSLocalizedString("Could not commit changes due to input validation error(s).", comment: "")
        }
    }
}

enum PasswordEditingMode {
    case create
    case modify
}

class PasswordEditViewController: UITableViewController {
    @IBOutlet weak var appTextField: UITextField!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var maskSwitch: UISwitch!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var commitButton: UIBarButtonItem!
    
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
        
        navigationController?.modalPresentationStyle = .fullScreen
        
        commitButton.isEnabled = false
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
        
        editingCancelled = false
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ApplicationListTableViewController {
            vc.selectionDelegate = self
            vc.dismissOnSelection = true
            vc.initialSelection = appTextField.text?.trimmingCharacters(in: .whitespaces) != "" ? appTextField.text : nil
        }
    }
    
    // MARK: - TableView
    
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
    
    // MARK: - Validation and Persistence
    
    func validateAndCommitChanges() throws {
        guard validateInputs() else { throw PasswordEditError.inputValidationAbortedCommitError }
        let app = appTextField.text!
        let user = userTextField.text!
        let password = "\(passwordTextField.text!)"
        
        switch editingMode {
        case .create:
            try passwordService.createRecord(app: app, user: user, password: password)
            
        case .modify:
            guard let record = passwordRecord else { fatalError() }
            record.app = app
            record.user = user
            try record.setPassword(password)
            try passwordService.updatePasswordRecord(record)
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
    
    @objc func dismissKeyboard() {
        appTextField.resignFirstResponder()
        userTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: - Actions
    
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
        commitButton.isEnabled = validateInputs()
    }
    
    @IBAction func maskSwitchToggled(_ sender: UISwitch) {
        passwordTextField.isSecureTextEntry = sender.isOn
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func commitButtonTapped(_ sender: UIBarButtonItem) {
        do {
            try validateAndCommitChanges()
            dismiss(animated: true)
        } catch {
            presentAlert(explaning: error, toViewController: self)
        }
    }
}

extension PasswordEditViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}

extension PasswordEditViewController: ApplicationListSelectionDelegate {
    func applicationWasSelected(withName name: String?) {
        if let name = name {
            appTextField.text = name
            textFieldValueDidChange(appTextField)
        }
    }
}
