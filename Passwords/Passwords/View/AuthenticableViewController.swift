//
//  AuthenticableViewController.swift
//  Passwords
//
//  Created by James Hadar on 12/21/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import UIKit

/// View controllers requiring authentication will subclass this (instead of UIViewController) to get consistent behavior throughout the app. TODO: Inheritence feels awkward, do Swift decorators exist?
class AuthenticableViewController: UIViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkAuthentication(animated: animated)
    }
    
    private func checkAuthentication(animated: Bool) {
        if !authService.authenticated {
            authService.authenticate()
        }
        print("checkAuthentication: \(authenticated ? "Authenticated" : "Not authenticated")")
    }
}
