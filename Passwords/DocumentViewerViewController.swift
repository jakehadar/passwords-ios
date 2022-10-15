//
//  DocumentViewerViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/15/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class DocumentViewerViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var url: URL?
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Viewer"
        textView.text = ""
        infoLabel.text = "No document loaded"
        
        toolbarItems = [.flexibleSpace(), UIBarButtonItem(customView: infoLabel), .flexibleSpace()]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = url {
            do {
                textView.text = try String(contentsOfFile: url.path, encoding: .utf8)
                infoLabel.text = url.lastPathComponent
            } catch {
                presentAlert(explaning: error, toViewController: self)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
