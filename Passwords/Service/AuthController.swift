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
    private var lastStartOfInactivityTime: Date?
    
    // User Defaults persistence keys
    public let kAuthEnabled = "authenticationEnabled"
    public let kAuthTimeout = "authenticationTimeout"
    
    var authenticated: Bool = false {
        didSet {
            if authenticated {
                applicationIsActive = true
            }
        }
    }
    
    var applicationIsActive: Bool = false {
        didSet {
            if !applicationIsActive {
                lastStartOfInactivityTime = Date()
            }
        }
    }
    
    init(_ rootViewController: UIViewController) {
        self.rootViewController = rootViewController
    }
    
    var secondsSinceLastStartOfInactivity: TimeInterval? {
        return lastStartOfInactivityTime?.timeIntervalSinceNow
    }
    
    func shouldAuthenticate() -> Bool {
        guard !UIDevice.isSimulator else { return false }
        
        let authEnabled = UserDefaults.standard.bool(forKey: kAuthEnabled)
        guard authEnabled else { return false }
        
        let timeout = UserDefaults.standard.integer(forKey: kAuthTimeout)
        if let timeElapsed = secondsSinceLastStartOfInactivity, Int(-1 * timeElapsed) >= timeout && !applicationIsActive {
            debugPrint("secondsSinceLastStartOfInactivity: \(Int(-1 * timeElapsed)), timeout: \(timeout)")
            authenticated = false
        }
        return !authenticated
    }
    
    func authenticate() {
        if shouldAuthenticate() {
            let vc = AuthenticationViewController.instantiate()
            vc.authController = self
            rootViewController.present(vc, animated: false)
        }
    }
}
