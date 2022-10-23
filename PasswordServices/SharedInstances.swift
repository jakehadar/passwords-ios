//
//  SharedInstances.swift
//  PasswordServices
//
//  Created by James Hadar on 10/22/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation

public let kAppGroupName = "group.ar.had.Passwords"
public let sharedKeychain = KeychainWrapper(serviceName: Bundle.main.bundleIdentifier!, accessGroup: kAppGroupName)
public let sharedDefaults = UserDefaults(suiteName: kAppGroupName)!
public let sharedAuthController = AuthController.default
public let sharedPasswordService = PasswordService.default
