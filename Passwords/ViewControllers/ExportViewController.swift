//
//  ExportViewController.swift
//  Passwords
//
//  Created by James Hadar on 12/13/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import UIKit
import PasswordServices

class ExportViewController: UIViewControllerAuthenticable {
    var passwordService: PasswordService = sharedPasswordService

    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var exportTextView: UITextView!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    @IBOutlet weak var saveToDocumentsButton: UIBarButtonItem!
    
    private weak var saveToDocumentsFilenameTextField: UITextField?
    private weak var saveToDocumentsFilenameSaveAction: UIAlertAction?
    private weak var saveToDocumentsFilenameController: UIAlertController?
    private let kSaveToDocumentsFilenameControllerDefaultMessage = "Filename"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copyButton.isEnabled = false
        saveToDocumentsButton.isEnabled = false
    }
    
    func exportJson() throws {
        let passwords = passwordService.getRecords()
        let keychainEntries = passwords.reduce(into: [PasswordKeychainEntry]()) { $0.append(PasswordKeychainEntry(uuid: $1.uuid, text: $1.getPassword() ?? "")) }
        let jsonExportContainer = JSONExportContainer(passwords: passwords, keychainEntries: keychainEntries)
        let jsonExportString = prettyJsonString(try JSONEncoder().encode(jsonExportContainer))
        exportTextView.text = jsonExportString
    }
    
    func prettyJsonString(_ data: Data) -> String? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let data2 = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
            let prettyStr = NSString(data: data2, encoding: String.Encoding.utf8.rawValue) {
                return prettyStr as String
        }
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func copyTapped(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = exportTextView.text
        presentInfo("Copied to Clipboard", toViewController: self)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let defaultFileName = "passwords_export_\(dateFormatter.string(from: Date())).json"
        
        let ac = UIAlertController(title: "Save to Documents", message: kSaveToDocumentsFilenameControllerDefaultMessage, preferredStyle: .alert)
        ac.addTextField { [unowned self] textField in
            textField.tag = TextFieldTags.saveJsonExportToDocumentsFilenameField.rawValue
            textField.delegate = self
            textField.text = defaultFileName
            self.saveToDocumentsFilenameTextField = textField
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            if let fileName = self.saveToDocumentsFilenameTextField?.text?.trimmingCharacters(in: .whitespaces), fileName.isValidFilename() {
                let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
                do {
                    try exportTextView.text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                    let ac = UIAlertController(title: "Success", message: "Saved \(fileName) to Documents", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                } catch {
                    presentAlert(explaning: error, toViewController: self)
                }
            } else {
                let ac = UIAlertController(title: "Error", message: "Did not save. Filename '\(self.saveToDocumentsFilenameTextField?.text ?? "")' is invalid.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
        saveToDocumentsFilenameController = ac
        saveToDocumentsFilenameSaveAction = saveAction
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(saveAction)
        present(ac, animated: true)
    }
    
    @IBAction func exportTapped(_ sender: UIBarButtonItem) {
        self.exportButton.isEnabled = false
        let ac = UIAlertController(title: "Warning", message: "This action will show all passwords in plain text.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [unowned self] _ in
            self.exportButton.isEnabled = true
        })
        ac.addAction(UIAlertAction(title: "Continue", style: .default) { [unowned self] _ in
            do {
                try self.exportJson()
                self.copyButton.isEnabled = true
                self.saveToDocumentsButton.isEnabled = true
                self.exportButton.isEnabled = false
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
        })
        self.present(ac, animated: true, completion: nil)
    }
}

extension ExportViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if TextFieldTags(rawValue: textField.tag) == .saveJsonExportToDocumentsFilenameField, let oldText = textField.text, let newRange = Range(range, in: oldText) {
            let newText = oldText.replacingCharacters(in: newRange, with: string)
            let endsWithJsonExtension = newText.lowercased().hasSuffix(".json")
            let isValidFilename = newText.isValidFilename()
            let textIsValid = endsWithJsonExtension && isValidFilename
            saveToDocumentsFilenameSaveAction?.isEnabled = textIsValid
            saveToDocumentsFilenameController?.message = textIsValid ? kSaveToDocumentsFilenameControllerDefaultMessage : "'\(newText)' is an invalid filename"
        }
        return true
    }
}
