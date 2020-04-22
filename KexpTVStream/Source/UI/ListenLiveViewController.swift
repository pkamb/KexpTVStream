//
//  ListenLiveViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/7/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class ListenLiveViewController: UIViewController {
    private let playlistVC = PlaylistTableVC()
    private let djVC = DJViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        constructSubviews()
        constructConstraints()
    }
    
    func setupViews() {
        addChild(playlistVC)
        playlistVC.didMove(toParent: self)
        playlistVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(djVC)
        djVC.didMove(toParent: self)
        djVC.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constructSubviews() {
        view.addSubview(playlistVC.view)
        view.addSubview(djVC.view)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [djVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             djVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [playlistVC.view.topAnchor.constraint(equalTo: view.centerYAnchor),
             playlistVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             playlistVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             playlistVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
}
