//
//  AuthenticationViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/24/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthenticationViewController: UIViewController {
    var authService: AuthService? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Locked"
    }
    
    static func instantiate() -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthenticationViewController") as UIViewController
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doAuthentication()
    }
    
    private func doAuthentication() {
        #if DEBUG
        authService?.authResult(true)
        dismiss(animated: true)
        #else
        biometricAuthentication()
        #endif
    }
    
    private func biometricAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to unlock."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    self.authService?.authResult(success)
                    if success {
                        self.dismiss(animated: true)
                    }
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
