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
    
    init(navigationController: UINavigationController, recordManager: PasswordRecordManager) {
        self.navigationController = navigationController
        self.recordManager = recordManager
    }
    
    func start() {
        let vc = MainViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func editPassword(passwordRecord: PasswordRecord) {
        let vc = PasswordEditViewController.instantiate()
        vc.coordinator = self
        vc.passwordRecord = passwordRecord
        vc.title = "Edit"
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addPassword() {
        let vc = PasswordEditViewController.instantiate()
        let navController = UINavigationController(rootViewController: vc)
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: vc, action: "dismiss")
        vc.coordinator = self
        vc.title = "Add"
        
        navigationController.present(navController, animated: true)
    }
    
    func passwordList() {
        let vc = PasswordListViewController.instantiate()
        let viewModel = PasswordListViewModel(coordinator: self, recordManager: recordManager, vc: vc)
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
    }
}
