//
//  Common.swift
//  Passwords
//
//  Created by James Hadar on 10/22/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import UIKit

func getTaskProgressViewController(storyboard: UIStoryboard?, view: UIView) -> TaskProgressViewController? {
    guard let vc = storyboard?.instantiateViewController(withIdentifier: "TaskProgressViewController") as? TaskProgressViewController else { return nil }
    vc.view.frame = CGRect(origin: view.center, size: CGSize(width: 200, height: 150))
    vc.view.center = CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds))
    vc.view.layer.cornerRadius = 10
    vc.activityIndicator.isHidden = true
    return vc
}

enum TextFieldTags: Int {
    case addNewApplicationNameField = 0
    case saveJsonExportToDocumentsFilenameField = 1
}

func presentAlert(explaning error: Error, toViewController vc: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
    let ac = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
    vc.present(ac, animated: true, completion: nil)
}

func findIndexPath<T: Equatable>(ofFirstElement e: T, in2DArray array: [[T]]) -> IndexPath? {
    for (i, section) in array.enumerated() {
        for (j, item) in section.enumerated() {
            if e == item {
                return IndexPath(row: j, section: i)
            }
        }
    }
    return nil
}
