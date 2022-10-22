//
//  PasswordDetailViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/23/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class PasswordDetailViewController: UIViewControllerAuthenticable {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var lastModifiedLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
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
            
            uuidLabel.text = record.uuid
            domainLabel.text = record.domain ?? ""
            urlLabel.text = record.url ?? ""
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
        if let nc = segue.destination as? UINavigationController, let vc = nc.children.first as? PasswordEditViewController {
            vc.passwordRecord = passwordRecord
        }
    }
    
    // MARK: - Actions
    
    @IBAction func unmaskButtonHold(_ sender: UIButton) {
        passwordField.isSecureTextEntry = false
    }
    
    @IBAction func unmaskButtonRelease(_ sender: UIButton) {
        passwordField.isSecureTextEntry = true
    }
    
    @IBAction func copyButtonTapped(_ sender: UIBarButtonItem) {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Copy Username", style: .default) { [unowned self] _ in
            UIPasteboard.general.string = self.userLabel.text
            presentInfo("Copied Username", toViewController: self)
        })
        ac.addAction(UIAlertAction(title: "Copy Password", style: .default) { [unowned self] _ in
            UIPasteboard.general.string = self.passwordField.text
            presentInfo("Copied Password", toViewController: self)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        guard let passwordToDelete = self.passwordRecord else { return }
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [unowned self] _ in
            do {
                try PasswordService.default.deleteRecord(passwordToDelete)
                self.passwordRecord = nil
                self.navigationController?.popViewController(animated: true)
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
