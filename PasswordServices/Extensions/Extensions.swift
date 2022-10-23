//
//  UIDevice+Extensions.swift
//  PasswordServices
//
//  Created by James Hadar on 10/22/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    public static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

extension String {
    public static let invalidFileNameCharactersRegex = "[^a-zA-Z0-9_\\.]+"
    
    public func convertToValidFileName() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let fullRange = trimmed.startIndex..<trimmed.endIndex
        let validName = trimmed.replacingOccurrences(of: String.invalidFileNameCharactersRegex,
                                           with: "-",
                                        options: .regularExpression,
                                          range: fullRange)
        return validName
    }
    
    public func isValidFilename() -> Bool {
        return self == convertToValidFileName()
    }
}
