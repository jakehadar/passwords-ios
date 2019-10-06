//
//  AuthenticationViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/24/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController, Storyboarded {
    
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Locked"
        
        doAuthentication()
    }
    
    private func doAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to unlock."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                    if success {
                        self.coordinator?.unlock()
                        self.dismiss(animated: true)
                    } else {
                        let ac = UIAlertController(title: "Authentication failed", message: "You identity couldn't be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func authenticateTapped(_ sender: UIButton) {
        doAuthentication()
    }
}

