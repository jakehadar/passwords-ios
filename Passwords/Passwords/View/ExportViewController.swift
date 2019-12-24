//
//  ExportViewController.swift
//  Passwords
//
//  Created by James Hadar on 12/13/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import UIKit

class ExportViewController: AuthenticableViewController {

    @IBOutlet weak var exportTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let data = passwordService.encodedPasswordData(), let jsonString = prettyJsonString(data) {
            exportTextView.text = jsonString
        } else {
            exportTextView.text = "Failed to export password records."
        }
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

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let filename = getDocumentsDirectory().appendingPathComponent("passwords_export.json")
        do {
            try exportTextView.text.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            let ac = UIAlertController(title: "Success", message: "Saved json export to: \n\(filename)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } catch {
            let ac = UIAlertController(title: "Failure", message: "Failed to export json to: \n\(filename)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true)
    }
}
