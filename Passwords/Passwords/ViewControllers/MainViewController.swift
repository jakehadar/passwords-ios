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

        // Do any additional setup after loading the view.
    }

    @IBAction func passwordListTapped(_ sender: UIButton) {
        coordinator?.passwordList()
    }
    @IBAction func editPasswordTapped(_ sender: UIButton) {
        coordinator?.editPassword()
    }
}
