//
//  PasswordDetailViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordDetailViewController: UIViewController {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    
    weak var passwordRecord: Password?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
        
        if let record = passwordRecord {
            title = record.app
            userLabel.text = record.user
            
            passwordField.isSecureTextEntry = true
            passwordField.text = record.getPassword()
            
            let dateModified = DateHelper.fromInt(record.modified)
            let unitsSinceLastModified = DateHelper.timeIntervalString(since: dateModified)
            lastModifiedLabel.text = "Last modified \(unitsSinceLastModified) ago"
        } else {
            // Only case where this code path should be entered is when passwordRecord is deleted from the Edit modal.
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let nc = segue.destination as? UINavigationController, let vc = nc.childViewControllers.first as? PasswordEditViewController {
            vc.passwordRecord = passwordRecord
        }
    }
    
    func deletePasswordRecord() {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            guard let record = self.passwordRecord else { fatalError() }
            
            do {
                try passwordService.deletePasswordRecord(record)
                self.passwordRecord = nil
                self.navigationController?.popViewController(animated: true)
            } catch {
                let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        ac.addAction(deleteAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func unmaskButtonHold(_ sender: UIButton) {
        if authController.authenticated {
            passwordField.isSecureTextEntry = false
        } else {
            authController.authenticate()
        }
    }
    
    @IBAction func unmaskButtonRelease(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        deletePasswordRecord()
    }
}
