//
//  CurrentlyPlayingViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/7/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class CurrentlyPlayingViewController: UIViewController {
    private let playlistVC = PlaylistTableVC()
    private let djVC = DJViewController()
    
    private let listenLiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Listen Live", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    } ()
    
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
        view.addSubview(listenLiveButton)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [djVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             djVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [listenLiveButton.topAnchor.constraint(equalTo: djVC.view.bottomAnchor),
             listenLiveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
