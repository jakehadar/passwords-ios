//
//  ViewController+Authenticable.swift
//  Passwords
//
//  Created by James Hadar on 10/18/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import UIKit

open class UIViewControllerAuthenticable: UIViewController {

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sharedAuthController.authenticate()
    }
    
}


open class UITableViewControllerAuthenticable: UITableViewController {
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sharedAuthController.authenticate()
    }
    
}
