//
//  MainViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""
    }

    @IBAction func authenticateTapped(_ sender: UIButton) {
        // TODO: biometric authentication
        coordinator?.passwordList()
    }
}
