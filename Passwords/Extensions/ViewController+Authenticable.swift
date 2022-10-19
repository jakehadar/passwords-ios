//
//  ViewController+Authenticable.swift
//  Passwords
//
//  Created by James Hadar on 10/18/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

class UIViewControllerAuthenticable: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AuthController.default.authenticate()
    }
    
}


class UITableViewControllerAuthenticable: UITableViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AuthController.default.authenticate()
    }
    
}
