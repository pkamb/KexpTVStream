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
    private let playlistVC = PlaylistCollectionVC()
    private let djVC = DJViewController()
    private let networkManager = NetworkManager()
    private let archiveManager = ArchiveManager()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 30
        return stackView
    }()
    
    private let currentlyPlayingStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 30
        return stackView
    }()
    
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
        button.isHidden = true
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "playButton"), for: .normal)
        return button
    }()
    
    private let jumpToTimeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Jump to Time", for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        constructSubviews()
        constructConstraints()
    }
    
    func setupViews() {
        playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .primaryActionTriggered)
        listenLiveButton.addTarget(self, action: #selector(playLiveStreamAction), for: .primaryActionTriggered)
        jumpToTimeButton.addTarget(self, action: #selector(archiveStartTimes), for: .primaryActionTriggered)
        
        addChild(playlistVC)
        playlistVC.didMove(toParent: self)
        playlistVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(djVC)
        djVC.didMove(toParent: self)
        djVC.view.translatesAutoresizingMaskIntoConstraints = false
        djVC.view.layer.borderColor = UIColor.black.cgColor
        djVC.view.layer.borderWidth = 1.0
        
        showLoadingIndicator()
        djVC.updateShowDetails {
            DispatchQueue.main.async {
                self.removeLoadingIndicator()
            }
        }
    }
    
    func constructSubviews() {
        view.addSubview(mainStackView)
        view.addSubview(playlistVC.view)
        
        buttonStackView.addArrangedSubview(listenLiveButton)
        buttonStackView.addArrangedSubview(jumpToTimeButton)
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(currentlyPlayingStackView)

        currentlyPlayingStackView.addArrangedSubview(playPauseButton)
        currentlyPlayingStackView.addArrangedSubview(djVC.view)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )

        NSLayoutConstraint.activate(
            [playlistVC.view.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: 20),
             playlistVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             playlistVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             playlistVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
    
    @objc
    private func playLiveStreamAction(_ sender: UIButton) {
        playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        Player.sharedInstance.play(with: retrieveLiveStream())
        
        djVC.currentlyPlayingArchiveShow = nil
        
        djVC.updateShowDetails {
            DispatchQueue.main.async {
                self.removeLoadingIndicator()
            }
        }
        
        playlistVC.livePlaylistShowTime()
        jumpToTimeButton.isHidden = true
        listenLiveButton.isHidden = true
    }
    
    @objc
    private func playPauseAction(_ sender: UIButton) {
        if Player.sharedInstance.isPlaying {
            Player.sharedInstance.pause()
            playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
        } else {
            Player.sharedInstance.resume()
            playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }
    
    @objc
    private func archiveStartTimes(_ sender: UIButton) {
        guard let archiveShow = djVC.currentlyPlayingArchiveShow else { return }
        
        let startTimesVC = StartTimesCollectionViewController(archiveShow: archiveShow)
        startTimesVC.startTimesDelegate = self
        startTimesVC.title = "\(archiveShow.show.programName ?? "") with \(archiveShow.show.hostNames?.first ?? "")"
        let navigationController = UINavigationController(rootViewController: startTimesVC)
        show(navigationController, sender: self)
    }
    
    private func retrieveLiveStream() -> URL? {
        return KEXPPower.availableStreams?.first?.streamURL
    }
    
    private func playArchiveShow(archiveShow: ArchiveShow, startTimeDate: Date? = nil) {
        archiveManager.getStreamURLs(for: archiveShow, playbackStartDate: startTimeDate) { [weak self] streamURLs, offset in
            Player.sharedInstance.playArchive(with: streamURLs, offset: offset)
            
            DispatchQueue.main.async {
                self?.showLoadingIndicator()
                self?.jumpToTimeButton.isHidden = false
                self?.listenLiveButton.isHidden = false
                self?.playlistVC.updateArchievePlaylistShowTime(startTime: startTimeDate ?? archiveShow.show.startTime)
                self?.djVC.currentlyPlayingArchiveShow = archiveShow

                self?.djVC.updateShowDetails {
                    DispatchQueue.main.async {
                        self?.removeLoadingIndicator()
                    }
                }
                
                self?.playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
            }
        }
    }
}

extension CurrentlyPlayingViewController: ArchiveDelegate {
    func playShow(archiveShow: ArchiveShow) {
        playArchiveShow(archiveShow: archiveShow)
    }
}

extension CurrentlyPlayingViewController: StartTimesDelegate {
    func playShow(archiveShow: ArchiveShow, archiveShowStart: ArchiveShowStart) {
        playArchiveShow(archiveShow: archiveShow, startTimeDate: archiveShowStart.startTimeDate)
    }
}
