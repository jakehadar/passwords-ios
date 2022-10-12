//
//  ExportViewController.swift
//  Passwords
//
//  Created by James Hadar on 12/13/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import UIKit

class ExportViewController: UIViewController {

    @IBOutlet weak var exportButton: UIBarButtonItem!
    @IBOutlet weak var exportTextView: UITextView!
    @IBOutlet weak var copyButton: UIBarButtonItem!
    @IBOutlet weak var saveToDocumentsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authController.authenticate()
        copyButton.isEnabled = false
        saveToDocumentsButton.isEnabled = false
        exportTapped(exportButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func exportJson() throws {
        let passwords = passwordService.getPasswordRecords()
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
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
        let alert = UIAlertController(title: "Copied", message: "Copied exported data to clipboard.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let filename = getDocumentsDirectory().appendingPathComponent("passwords_export.json")
        do {
            try exportTextView.text.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            let ac = UIAlertController(title: "Success", message: "Saved json export to: \n\(filename)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } catch {
            presentAlert(explaning: error, toViewController: self)
        }
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
