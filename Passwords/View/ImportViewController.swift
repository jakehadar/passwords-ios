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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    }
    @IBAction func parseTapped(_ sender: UIBarButtonItem) {
        do {
            let jsonData = Data(self.jsonTextView.text.utf8)
            let jsonContainer: JSONExportContainer = try JSONDecoder().decode(JSONExportContainer.self, from: jsonData)
            let passwordEntities = jsonContainer.passwords
            let keychainEntities = jsonContainer.keychainEntries
            let alert = UIAlertController(title: "Import", message: "Import \(passwordEntities.count) password entries? This may result in duplicates.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Import", style: .destructive, handler: { [passwordEntities, keychainEntities] _ in
                let uuidKeychainDict = keychainEntities.reduce(into: Dictionary<String, String>()) { $0[$1.uuid] = $1.text }
                var savedEntitiesCount = 0
                do {
                    try passwordEntities.forEach {
                        try passwordService.createPasswordRecord(app: $0.app, user: $0.user, password: uuidKeychainDict[$0.uuid] ?? "")
                        savedEntitiesCount += 1
                    }
                } catch {
                    let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                let alert = UIAlertController(title: "Done", message: "Imported \(savedEntitiesCount)/\(passwordEntities.count) records successfully.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } catch {
            let alert = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}
