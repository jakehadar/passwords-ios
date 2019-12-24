//
//  AuthService.swift
//  Passwords
//
//  Created by James Hadar on 12/24/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import Foundation
import UIKit

class AuthService {
    private var rootViewController: UIViewController
    
    public private(set) var authenticated: Bool = false
    
    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    // TODO: figure out access control best practices
    func authResult(_ result: Bool) {
        authenticated = result
    }
    
    func authenticate() {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else { fatalError() }
        vc.authService = self
        rootViewController.present(vc, animated: true)
    }
    
    func deauthenticate() {
        authenticated = false
    }
}
