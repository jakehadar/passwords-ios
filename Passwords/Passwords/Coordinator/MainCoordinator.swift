
//
//  MainCoordinator.swift
//  Passwords
//
//  Created by James Hadar on 4/21/18.
//  Copyright © 2018 James Hadar. All rights reserved.
//


// THIS IS LEGACY and being replaced with storyboards

//import UIKit
//
//class MainCoordinator: NSObject {
//    var childCoordinators = [MainCoordinator]()
//    var navigationController: UINavigationController
//    var passwordService: PasswordServiceProtocol
//    
//    var passwordListViewController: PasswordListViewController?
//    
//    private var authenticated = false
//    
//    init(navigationController: UINavigationController, passwordService: PasswordServiceProtocol) {
//        
//        fatalError("THIS CLASS IS LEGACY and being replaced with storyboards")
//        self.navigationController = navigationController
//        self.passwordService = passwordService
////        NotificationCenter.default.addObserver(self, selector: #selector(showAuthentication), name: Notification.Name.UIApplicationWillResignActive, object: nil)
//        #if DEBUG
//            authenticated = true
//        #endif
//    }
//    
//    func unlock() {
//        authenticated = true
//    }
//    
//    func isAuthenticated() -> Bool {
//        return authenticated
//    }
//    
//    func start() {
//        if !authenticated { showAuthentication() }
//        showPasswordList()
//    }
//    
//    @objc func showAuthentication() {
//        let vc = AuthenticationViewController()
////        vc.coordinator = self
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .fullScreen
//        navigationController.present(navController, animated: false)
//    }
//    
//    func showPasswordDetail(passwordRecord: Password) {
//        if !authenticated { showAuthentication() }
//        let vc = PasswordDetailViewController()
//        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: vc, action: Selector("edit"))
////        vc.coordinator = self
//        vc.passwordRecord = passwordRecord
//        
//        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func showPasswordEditor(passwordRecord: Password?) {
//        if !authenticated { showAuthentication() }
//        let vc = PasswordEditViewController()
////        vc.configure(coordinator: self, service: passwordService, record: passwordRecord)
//        vc.title = "Edit password"
//        
//        navigationController.pushViewController(vc, animated: true)
//    }
//    
//    func showPasswordCreator() {
//        if !authenticated { showAuthentication() }
//        let vc = PasswordEditViewController()
////        vc.configure(coordinator: self, service: passwordService, record: nil)
//        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: vc, action: "save")
//        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: vc, action: "cancel")
////        vc.coordinator = self
//        vc.title = "New password"
//        
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .fullScreen
//        navigationController.present(navController, animated: true)
//    }
//    
//    func showPasswordList() {
//        if !authenticated { showAuthentication() }
//        if let vc = passwordListViewController {
//            navigationController.popToViewController(vc, animated: true)
//        } else {
//            let controller = PasswordListDataController(service: passwordService)
//            let dataSource = PasswordListDataSource(controller: controller)
//            let vc = PasswordListViewController()
////            vc.configure(coordinator: self, controller: controller, dataSource: dataSource)
//            passwordListViewController = vc
//            navigationController.pushViewController(vc, animated: false)
//        }
//    }
//}
