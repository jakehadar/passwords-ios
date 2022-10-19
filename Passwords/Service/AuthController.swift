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
    static let `default` = AuthController()
    private var lastStartOfInactivityTime: Date?
    
    // User Defaults persistence keys
    static let kAuthEnabled = "authenticationEnabled"
    static let kAuthTimeout = "authenticationTimeout"
    
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
    
    private init() {}
    
    func topViewController() -> UIViewController {
        guard var vc = UIApplication.shared.delegate?.window??.rootViewController else { fatalError() }
        while let descendant = vc.presentedViewController {
            vc = descendant
        }
        return vc
    }
    
    var secondsSinceLastStartOfInactivity: TimeInterval? {
        return lastStartOfInactivityTime?.timeIntervalSinceNow
    }
    
    func shouldAuthenticate() -> Bool {
        guard !UIDevice.isSimulator else { return false }
        
        let authEnabled = UserDefaults.standard.bool(forKey: AuthController.kAuthEnabled)
        guard authEnabled else { return false }
        
        let timeout = UserDefaults.standard.integer(forKey: AuthController.kAuthTimeout)
        if let timeElapsed = secondsSinceLastStartOfInactivity, Int(-1 * timeElapsed) >= timeout && !applicationIsActive {
            debugPrint("secondsSinceLastStartOfInactivity: \(Int(-1 * timeElapsed)), timeout: \(timeout)")
            authenticated = false
        }
        return !authenticated
    }
    
    func authenticate() {
        if shouldAuthenticate() {
            let vc = AuthenticationViewController.instantiate(withAuthController: self)
            topViewController().present(vc, animated: false)
        }
    }
}
