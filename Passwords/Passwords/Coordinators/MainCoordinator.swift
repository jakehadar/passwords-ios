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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func editPassword() {
        let vc = PasswordEditViewController.instantiate()
        vc.coordinator = self
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
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
