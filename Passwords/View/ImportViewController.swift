//
//  ImportViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/9/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class ImportViewController: UIViewController {

    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var importButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authController.authenticate()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func pasteTapped(_ sender: UIBarButtonItem) {
        jsonTextView.text = UIPasteboard.general.string
        importButton.isEnabled = jsonTextView.text.count > 0 ? true : false
    }
    
    @IBAction func clearTapped(_ sender: UIBarButtonItem) {
        jsonTextView.text = ""
        importButton.isEnabled = false
    }
    
    
    
    @IBAction func importTapped(_ sender: UIBarButtonItem) {
        do {
            let jsonData = Data(self.jsonTextView.text.utf8)
            let jsonContainer: JSONExportContainer = try JSONDecoder().decode(JSONExportContainer.self, from: jsonData)
            let passwordEntities = jsonContainer.passwords
            let keychainEntities = jsonContainer.keychainEntries
            let ac = UIAlertController(title: "Import", message: "Import \(passwordEntities.count) password entries? This may result in duplicates.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Import", style: .destructive, handler: { [passwordEntities, keychainEntities, unowned self] _ in
                let uuidKeychainDict = keychainEntities.reduce(into: Dictionary<String, String>()) { $0[$1.uuid] = $1.text }
                do {
                    try passwordEntities.forEach { try passwordService.createPasswordRecord(app: $0.app, user: $0.user, password: uuidKeychainDict[$0.uuid] ?? "") }
                } catch {
                    presentAlert(explaning: error, toViewController: self)
                }
                self.importButton.isEnabled = false
                let ac = UIAlertController(title: "Done", message: "Successfully imported \(passwordEntities.count) records.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(ac, animated: true, completion: nil)
        } catch {
            presentAlert(explaning: error, toViewController: self)
        }
    }
}

extension ImportViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        importButton.isEnabled = textView.text.count > 0 ? true : false
    }
}
