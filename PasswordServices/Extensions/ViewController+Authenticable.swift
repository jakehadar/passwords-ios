//
//  ViewController+Authenticable.swift
//  Passwords
//
//  Created by James Hadar on 10/18/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

open class UIViewControllerAuthenticable: UIViewController {

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sharedAuthController.authenticate()
    }
    
}


open class UITableViewControllerAuthenticable: UITableViewController {
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        sharedAuthController.authenticate()
    }
    
}
