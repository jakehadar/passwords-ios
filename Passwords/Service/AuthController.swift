//
//  AuthController.swift
//  Passwords
//
//  Created by James Hadar on 12/24/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import Foundation
import UIKit

/// Responsible for holding authentication state, and displaying the authentication modal.
class AuthController {
    private var rootViewController: UIViewController
    
    public private(set) var authenticated: Bool = false {
        didSet { debugPrint("AuthController: \(authenticated ? "Authenticated" : "Not authenticated")") }
    }
    
    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    // TODO: figure out access control best practices
    func authResult(_ result: Bool) {
        authenticated = result
    }
    
    func authenticate() {
        debugPrint("AuthController: authenticating...")
        if UIDevice.isSimulator {
            self.authenticated = true
        } else {
            if !authenticated {
                let vc = AuthenticationViewController.instantiate()
                vc.authController = self
                rootViewController.present(vc, animated: true)
            }
        }
    }
    
    func deauthenticate() {
        authenticated = false
    }
}
