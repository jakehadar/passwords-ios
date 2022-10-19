//
//  TaskProgressViewController.swift
//  Passwords
//
//  Created by James Hadar on 10/16/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class TaskProgressViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var message: String = "Please wait..."{
        didSet {
            messageLabel.text = message
        }
    }
    
    var progress: Float = 0 {
        didSet {
            progressBar.setProgress(progress, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = message
        progressBar.progress = progress
        activityIndicator.startAnimating()
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

}
