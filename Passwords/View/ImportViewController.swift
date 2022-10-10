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
    @IBAction func parseTapped(_ sender: UIBarButtonItem) {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(self.jsonTextView.text), let jsonContainer: JSONExportContainer = try? decoder.decode(JSONExportContainer.self, from: jsonData) {
            // continue doing stuff
            let passwordEntities = jsonContainer.passwords
            let keychainEntities = jsonContainer.keychainEntries
            
            let alert = UIAlertController(title: "Import", message: "Import \(passwordEntities.count) password entries?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Import", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Could not parse JSON input. Please double check syntax and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
}
