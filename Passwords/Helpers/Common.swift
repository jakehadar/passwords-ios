//
//  Common.swift
//  Passwords
//
//  Created by James Hadar on 10/11/22.
//  Copyright © 2022 James Hadar. All rights reserved.
//

import Foundation
import UIKit

func presentAlert(explaning error: Error, toViewController vc: UIViewController) {
    let ac = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    vc.present(ac, animated: true, completion: nil)
}
