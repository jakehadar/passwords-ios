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
    
    var appNames: [String] {
        return service.getAppNames().sorted()
    }
    
    var recordsForApp: Dictionary<String, [Password]> {
        let result = Dictionary(grouping: service.getPasswordRecords(), by: { $0.app })
        return result
    }
    
    static let `default` = PasswordListDataController(service: passwordService)
    
    init(service: PasswordServiceProtocol) {
        self.service = service
        reloadData()
    }
    
    func reloadData() {
        service.reloadData()
    }
}
