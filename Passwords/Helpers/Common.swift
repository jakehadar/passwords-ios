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
