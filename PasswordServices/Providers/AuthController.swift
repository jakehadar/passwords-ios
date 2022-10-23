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
public class AuthController {
    public static let `default` = AuthController()
    
    // User Defaults persistence keys
    public static let kAuthEnabled = "authenticationEnabled"
    public static let kAuthTimeout = "authenticationTimeout"
    public static let kAuthTimeoutStartTime = "authenticationTimeoutStartTime"
    
    public var authenticated: Bool = false {
        didSet {
            if authenticated {
                applicationIsActive = true
            }
        }
    }
    
    public var applicationIsActive: Bool = false {
        didSet {
            if !applicationIsActive {
                sharedDefaults.set(Date(), forKey: AuthController.kAuthTimeoutStartTime)
            }
        }
    }
    
    private init() {}
    
    private func topViewController() -> UIViewController {
        guard var vc = UIApplication.shared.delegate?.window??.rootViewController else { fatalError() }
        while let descendant = vc.presentedViewController {
            vc = descendant
        }
        return vc
    }
    
    private var timeoutCounterSeconds: TimeInterval? {
        return (sharedDefaults.object(forKey: AuthController.kAuthTimeoutStartTime) as? Date)?.timeIntervalSinceNow
    }
    
    private func shouldAuthenticate() -> Bool {
        let authEnabled = sharedDefaults.bool(forKey: AuthController.kAuthEnabled)
        guard authEnabled else { return false }
        guard !applicationIsActive else { return false }
        guard !UIDevice.isSimulator else { return false }
        
        let timeout = sharedDefaults.integer(forKey: AuthController.kAuthTimeout)
        if let timeElapsed = timeoutCounterSeconds, Int(-1 * timeElapsed) >= timeout {
            debugPrint("timeoutCounterSeconds: \(Int(-1 * timeElapsed)), timeout: \(timeout)")
            authenticated = false
        }
        return !authenticated
    }
    
    public func authenticate() {
        if shouldAuthenticate() {
            let vc = AuthenticationViewController.instantiate(withAuthController: self)
            topViewController().present(vc, animated: false)
        }
    }
}
