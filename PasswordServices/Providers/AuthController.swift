//
//  AuthController.swift
//  Passwords
//
//  Created by James Hadar on 12/24/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import Foundation
import UIKit

public enum ActivityState {
    case active
    case inactive
}

/// Responsible for holding authentication state, and displaying the authentication modal.
public class AuthController {
    public static let `default` = AuthController()
    
    // User Defaults persistence keys
    public static let kAuthEnabled = "authenticationEnabled"
    public static let kAuthTimeout = "authenticationTimeout"
    public static let kAuthTimeoutStartTime = "authenticationTimeoutStartTime"
    
    private var isAuthenticating = false
    
    public internal(set) var authenticated: Bool = false {
        didSet {
            if authenticated {
                isAuthenticating = false
                activityState = .active
            }
        }
    }
    
    public private(set) var activityState: ActivityState = .inactive {
        didSet {
            if oldValue == .active && activityState == .inactive {
                sharedDefaults.set(Date(), forKey: AuthController.kAuthTimeoutStartTime)
            }
        }
    }
    
    // Call this hook from the AppDelegate's applicationDidEnterBackground
    public func applicationBecameInactiveHook() {
        activityState = .inactive
    }
    
    // Call this hook from the AppDelegate's applicationDidBecomeActive
    public func applicationBecameActiveHook() {
        activityState = .active
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
        guard !isAuthenticating else { return false }
        let authEnabled = sharedDefaults.bool(forKey: AuthController.kAuthEnabled)
        guard authEnabled else { return false }
        guard activityState == .inactive else { return false }
        
        let timeout = sharedDefaults.integer(forKey: AuthController.kAuthTimeout)
        if let timeElapsed = timeoutCounterSeconds, Int(-1 * timeElapsed) >= timeout {
            debugPrint("timeoutCounterSeconds: \(Int(-1 * timeElapsed)), timeout: \(timeout)")
            authenticated = false
        }
        return !isAuthenticating && !authenticated
    }
    
    //TODO: This should be synchronized or locked
    public func authenticate() {
        if shouldAuthenticate() {
            guard !isAuthenticating else { return }
            isAuthenticating = true
            let vc = AuthenticationViewController.instantiate(withAuthController: self)
            topViewController().present(vc, animated: false)
        }
    }
}
