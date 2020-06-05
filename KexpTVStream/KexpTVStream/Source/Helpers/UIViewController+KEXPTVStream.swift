//
//  UIViewController+KEXPTVStream.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 6/5/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(with title: String?, message: String) {
        let alert = UIAlertController(title: title,  message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }
}
