//
//  PasswordListDataController.swift
//  Passwords
//
//  Created by James Hadar on 10/6/19.
//  Copyright © 2019 James Hadar. All rights reserved.
//

import Foundation

protocol PasswordListDataControllerProtocol {
    var appNames: [String] { get }
    var recordsForApp: Dictionary<String, [Password]> { get }
    func reloadData()
}

class PasswordListDataController: PasswordListDataControllerProtocol {
    private var service: PasswordServiceProtocol
    
    public private(set) var appNames = [String]()
    public private(set) var recordsForApp = Dictionary<String, [Password]>()
    
    init(service: PasswordServiceProtocol) {
        self.service = service
        reloadData()
    }
    
    func reloadData() {
        appNames = service.getAppNames()
        appNames.sort()
        
        for app in appNames {
            recordsForApp[app] = service.getPasswordRecords(forApp: app)
        }
    }
}
