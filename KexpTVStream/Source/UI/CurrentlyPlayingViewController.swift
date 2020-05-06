//
//  CurrentlyPlayingViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/7/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower
import UIKit

class CurrentlyPlayingViewController: UIViewController {
    private let playlistVC = PlaylistTableVC()
    private let djVC = DJViewController()
    private let networkManager = NetworkManager()
    private let archiveManager = ArchiveManager()
    private var playingArhieve = false
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    private let listenLiveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Listen Live", for: .normal)
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play", for: .normal)
        return button
    }()
    
    private let jumpToTimeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Jump to Time", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        constructSubviews()
        constructConstraints()
        
    //    showLoadingIndicator()
    }
    
    func setupViews() {
        playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .primaryActionTriggered)
        listenLiveButton.addTarget(self, action: #selector(playLiveStreamAction), for: .primaryActionTriggered)
        
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
        view.addSubview(buttonStackView)

        buttonStackView.addArrangedSubview(listenLiveButton)
        buttonStackView.addArrangedSubview(playPauseButton)
        buttonStackView.addArrangedSubview(jumpToTimeButton)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [djVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             djVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
        NSLayoutConstraint.activate(
            [buttonStackView.topAnchor.constraint(equalTo: djVC.view.bottomAnchor, constant: 50),
             buttonStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
    
    @objc
    private func playLiveStreamAction(_ sender: UIButton) {
        playPauseButton.setTitle("Pause", for: .normal)
        Player.sharedInstance.play(with: retrieveLiveStream())
        playingArhieve = false
    }
    
    @objc
    private func playPauseAction(_ sender: UIButton) {
        if Player.sharedInstance.isPlaying {
            Player.sharedInstance.pause()
            playPauseButton.setTitle("Play", for: .normal)
        } else {
            Player.sharedInstance.resume()
            playPauseButton.setTitle("Pause", for: .normal)
        }
    }
    
    private func retrieveLiveStream() -> URL? {
        return KEXPPower.availableStreams?.first?.streamURL
    }
}

extension CurrentlyPlayingViewController: ArchiveDelegate {
    func playShow(archiveShow: ArchiveShow) {
        archiveManager.getStreamURLs(for: archiveShow) { [weak self] streamURLs, offset in
            Player.sharedInstance.playArchive(with: streamURLs, offset: offset)
            self?.playingArhieve = true
            
            DispatchQueue.main.async {
                self?.playPauseButton.setTitle("Pause", for: .normal)
            }
        }
    }
}
