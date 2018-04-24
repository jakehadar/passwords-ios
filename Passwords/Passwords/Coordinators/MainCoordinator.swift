//
//  MainCoordinator.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var recordManager: PasswordRecordManager
    
    var passwordListViewController: PasswordListViewController?
    
    private var authenticated = false
    
    init(navigationController: UINavigationController, recordManager: PasswordRecordManager) {
        self.navigationController = navigationController
        self.recordManager = recordManager
        NotificationCenter.default.addObserver(self, selector: #selector(authenticate), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    func unlock() {
        authenticated = true
    }
    
    func start() {
        if !authenticated { authenticate() }
        passwordList()
    }
    
    @objc func authenticate() {
        authenticated = false
        let vc = AuthenticationViewController.instantiate()
        vc.coordinator = self
        navigationController.present(vc, animated: false) { [unowned self] in
            if !self.authenticated {
                self.authenticate()
            }
        }
    }
    
    func showPassword(passwordRecord: PasswordRecord) {
        if !authenticated { authenticate() }
        let vc = PasswordDetailViewController.instantiate()
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: vc, action: "edit")
        vc.coordinator = self
        vc.passwordRecord = passwordRecord
        vc.title = "Detail"
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func editPassword(passwordRecord: PasswordRecord) {
        if !authenticated { authenticate() }
        let vc = PasswordEditViewController.instantiate()
        vc.coordinator = self
        vc.passwordRecord = passwordRecord
        vc.title = "Edit"
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addPassword() {
        if !authenticated { authenticate() }
        let vc = PasswordEditViewController.instantiate()
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: vc, action: "save")
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: vc, action: "cancel")
        vc.coordinator = self
        vc.title = "Add"
        
        let navController = UINavigationController(rootViewController: vc)
        navigationController.present(navController, animated: true)
    }
    
    func passwordList() {
        if !authenticated { authenticate() }
        if let vc = passwordListViewController {
            navigationController.popToViewController(vc, animated: true)
        } else {
            let viewModel = PasswordListViewModel(coordinator: self, recordManager: recordManager)
            let vc = PasswordListViewController.instantiate()
            vc.viewModel = viewModel
            passwordListViewController = vc
            navigationController.pushViewController(vc, animated: true)
        }
    }
}
