//
//  Common.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import UIKit

enum TextFieldTags: Int {
    case addNewApplicationNameField = 0
    case saveJsonExportToDocumentsFilenameField = 1
}

func presentAlert(explaning error: Error, toViewController vc: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
    let ac = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
    vc.present(ac, animated: true, completion: nil)
}

func presentInfo(_ message: String, toViewController vc: UIViewController, forSeconds seconds: Double = 1.0, withSystemImageName systemName: String = "checkmark.circle") {
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

func getTaskProgressViewController(storyboard: UIStoryboard?, view: UIView) -> TaskProgressViewController? {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "TaskProgressViewController") as? TaskProgressViewController else { return nil }
    vc.view.frame = CGRect(origin: view.center, size: CGSize(width: 200, height: 150))
    vc.view.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
    vc.view.layer.cornerRadius = 10
    vc.activityIndicator.isHidden = true
    return vc
}

func formatAuthTimeoutText(_ seconds: Int) -> String {
    if seconds < 1 {
        return "Instantly"
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

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

func getOrphanedKeychainKeys() throws -> [String] {
    let keychainKeys = try sharedKeychain.allKeys()
    let passwordUUIDs = Set(PasswordService.default.getRecords().map { $0.uuid })
    let orphanedKeys = keychainKeys.subtracting(passwordUUIDs)
    return orphanedKeys.reduce(into: [String]()) { $0.append($1) }
}

func getActiveKeychainKeys() throws -> [String] {
    let keychainKeys = try sharedKeychain.allKeys()
    let passwordUUIDs = Set(PasswordService.default.getRecords().map { $0.uuid })
    let activeKeys = keychainKeys.union(passwordUUIDs)
    return activeKeys.reduce(into: [String]()) { $0.append($1) }
}

extension UIDevice {
    static var isSimulator: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }()
}

extension String {
    static let invalidFileNameCharactersRegex = "[^a-zA-Z0-9_\\.]+"
    
    func convertToValidFileName() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let fullRange = trimmed.startIndex..<trimmed.endIndex
        let validName = trimmed.replacingOccurrences(of: String.invalidFileNameCharactersRegex,
                                           with: "-",
                                        options: .regularExpression,
                                          range: fullRange)
        return validName
    }
    
    func isValidFilename() -> Bool {
        return self == convertToValidFileName()
    }
}
