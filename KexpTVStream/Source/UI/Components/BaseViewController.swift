//
//  BaseViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/23/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundLayer = ThemeManager.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)

        setupViews()
        constructSubviews()
        constructConstraints()
    }
    
    func setupViews() {}
    func constructSubviews() {}
    func constructConstraints() {}
}
