//
//  ImportViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/9/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class ImportViewController: UIViewControllerAuthenticable {

    @IBOutlet weak var jsonTextView: UITextView!
    @IBOutlet weak var importButton: UIBarButtonItem!
    
    private var selectedDocument: URL? {
        didSet {
            if let selectedDocument = selectedDocument {
                loadText(fromUrl: selectedDocument)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        importButton.isEnabled = false
    }
    
    func loadText(fromUrl url: URL) {
        do {
            jsonTextView.text = try String(contentsOfFile: url.path, encoding: .utf8)
            importButton.isEnabled = true
        } catch {
            presentAlert(explaning: error, toViewController: self)
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DocumentsTableViewController {
            vc.selectionDelegate = self
            vc.dismissOnSelection = true
        } else if let nc = segue.destination as? UINavigationController, let vc = nc.topViewController as? DocumentsTableViewController {
            vc.selectionDelegate = self
            vc.dismissOnSelection = true
        }
    }
    
    // MARK: - Actions
    
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
                let progressView = getTaskProgressViewController(storyboard: storyboard, view: view)!
                addChildViewController(progressView)
                view.addSubview(progressView.view)
                progressView.didMove(toParentViewController: self)
                
                DispatchQueue.global(qos: .userInitiated).async {
                    var progressCounter = 0
                    let progressLimit = passwordEntities.count
                    let uuidKeychainDict = keychainEntities.reduce(into: Dictionary<String, String>()) { $0[$1.uuid] = $1.text }
                    do {
                        try passwordEntities.forEach {
                            if KeychainWrapper.standard.hasValue(forKey: $0.uuid) {
                                let pw = Password(uuid: $0.uuid, app: $0.app, user: $0.user, created: $0.created, modified: $0.modified)
                                try PasswordService.default.updatePasswordRecord(pw)
                            } else {
                                try PasswordService.default.createPasswordRecord(app: $0.app, user: $0.user, password: uuidKeychainDict[$0.uuid] ?? "", created: $0.created, modified: $0.modified, uuid: $0.uuid)
                            }
                            progressCounter += 1
                            DispatchQueue.main.async {
                                progressView.progress = Float(progressCounter) / Float(progressLimit)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            presentAlert(explaning: error, toViewController: self)
                        }
                    }
                    DispatchQueue.main.async {
                        progressView.willMove(toParentViewController: nil)
                        progressView.view.removeFromSuperview()
                        progressView.removeFromParentViewController()
                        self.importButton.isEnabled = false
                        let ac = UIAlertController(title: "Done", message: "Successfully imported \(passwordEntities.count) records.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(ac, animated: true, completion: nil)
                    }
                }
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

extension ImportViewController: DocumentsListSelectionProtocol {
    func documentWasSelected(withUrl url: URL) {
        selectedDocument = url
    }
}
