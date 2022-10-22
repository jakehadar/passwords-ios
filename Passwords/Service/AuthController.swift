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
    
    // User Defaults persistence keys
    static let kAuthEnabled = "authenticationEnabled"
    static let kAuthTimeout = "authenticationTimeout"
    static let kAuthTimeoutStartTime = "authenticationTimeoutStartTime"
    
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
                UserDefaults.standard.set(Date(), forKey: AuthController.kAuthTimeoutStartTime)
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
    
    var timeoutCounterSeconds: TimeInterval? {
        return (UserDefaults.standard.object(forKey: AuthController.kAuthTimeoutStartTime) as? Date)?.timeIntervalSinceNow
    }
    
    func shouldAuthenticate() -> Bool {
        guard !UIDevice.isSimulator else { return false }
        
        let authEnabled = UserDefaults.standard.bool(forKey: AuthController.kAuthEnabled)
        guard authEnabled else { return false }
        
        let timeout = UserDefaults.standard.integer(forKey: AuthController.kAuthTimeout)
        if let timeElapsed = timeoutCounterSeconds, Int(-1 * timeElapsed) >= timeout && !applicationIsActive {
            debugPrint("timeoutCounterSeconds: \(Int(-1 * timeElapsed)), timeout: \(timeout)")
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
