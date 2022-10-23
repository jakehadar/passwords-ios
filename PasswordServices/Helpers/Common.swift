//
//  Common.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import UIKit

public func presentInfo(_ message: String, toViewController vc: UIViewController, forSeconds seconds: Double = 1.0, withSystemImageName systemName: String = "checkmark.circle") {
    let ac = UIAlertController(title: nil, message: message, preferredStyle: .alert)

    let glyph = UIImageView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    glyph.image = UIImage(systemName: systemName)
    glyph.tintColor = .lightGray
    ac.view.addSubview(glyph)
    
    vc.present(ac, animated: true, completion: nil)
    Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [ac] _ in
        ac.dismiss(animated: true)
    }
}

public func formatAuthTimeoutText(_ seconds: Int) -> String {
    if seconds < 1 {
        return "Immediately"
    } else if seconds < 60 {
        return "\(seconds) sec"
    } else {
        let minutes = Int(seconds / 60)
        let seconds = seconds % 60
        let mm = "\(minutes) min"
        let ss = "\(seconds) sec"
        return seconds == 0 ? "\(mm)" : "\(mm) \(ss)"
    }
}

public func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

public func getOrphanedKeychainKeys() throws -> [String] {
    let keychainKeys = try sharedKeychain.allKeys()
    let passwordUUIDs = Set(sharedPasswordService.getRecords().map { $0.uuid })
    let orphanedKeys = keychainKeys.subtracting(passwordUUIDs)
    return orphanedKeys.reduce(into: [String]()) { $0.append($1) }
}

public func getActiveKeychainKeys() throws -> [String] {
    let keychainKeys = try sharedKeychain.allKeys()
    let passwordUUIDs = Set(sharedPasswordService.getRecords().map { $0.uuid })
    let activeKeys = keychainKeys.union(passwordUUIDs)
    return activeKeys.reduce(into: [String]()) { $0.append($1) }
}


