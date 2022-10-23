//
//  AuthenticationViewController.swift
//  Passwords
//
//  Created by James Hadar on 4/24/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit
import LocalAuthentication

public class AuthenticationViewController: UIViewController {
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var authenticateButton: UIButton!
    @IBOutlet weak var simulatorWarningLabel: UILabel!
    var authController: AuthController? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locked"
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        blurEffectView.frame = self.view.frame
        self.view.insertSubview(blurEffectView, at: 0)
        
        if UIDevice.isSimulator {
            simulatorWarningLabel.isHidden = false
            authenticateButton.isHidden = true
            dismissButton.isHidden = false
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doAuthentication()
    }
    
    public static func instantiate(withAuthController authController: AuthController) -> AuthenticationViewController {
        guard let vc = UIStoryboard(name: "Main", bundle: Bundle(for: AuthenticationViewController.self)).instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController else { fatalError() }
        vc.authController = authController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    private func doAuthentication() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself to unlock."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    self.authController?.authenticated = success
                    if success {
                        self.dismiss(animated: false)
                    }
                }
            }
        } else if !UIDevice.isSimulator {
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
                self.authController?.authenticated = true
                self.dismiss(animated: false)
            })
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func dismissTapped(_ sender: UIButton) {
        self.authController?.authenticated = true
        self.dismiss(animated: false)
    }
    
    @IBAction func authenticateTapped(_ sender: UIButton) {
        doAuthentication()
    }
}
