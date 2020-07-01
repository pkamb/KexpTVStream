//
//  NowPlayingViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/7/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower
import MediaPlayer
import UIKit

class NowPlayingViewController: BaseViewController {
    private enum Style {
        static let liveButtonHeight = CGFloat(50)
        static let playlistViewTopInset = CGFloat(10)
    }
    
    private let playlistVC = PlaylistCollectionVC()
    private let djVC = DJViewController()
    private let networkManager = NetworkManager()
    private let archiveManager = ArchiveManager()
    private var isPlayingArchive = false

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20
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
        button.titleLabel?.font = ThemeManager.NowPlaying.ListenLive.font
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
        button.setImage(UIImage(named: "clock"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetPlaylistIfNeeded),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
        

        Player.shared.delegate = self
        setupRemoteCommandCenter()
        showLoadingIndicator()
        djVC.updateShowDetails(fireAnalytic: false) {
            DispatchQueue.main.async {
                self.removeLoadingIndicator()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isPlayingArchive {
            playlistVC.livePlaylistShowTime()
        }
        
        playlistVC.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
    }
    
    override func setupViews() {
        playPauseButton.addTarget(self, action: #selector(playPauseAction), for: .primaryActionTriggered)
        listenLiveButton.addTarget(self, action: #selector(playLiveStreamAction), for: .primaryActionTriggered)
        jumpToTimeButton.addTarget(self, action: #selector(archiveStartTimes), for: .primaryActionTriggered)
        
        let playButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseAction))
        playButtonRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue as Int)]
        view.addGestureRecognizer(playButtonRecognizer)
        
        addChild(playlistVC)
        playlistVC.didMove(toParent: self)
        playlistVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(djVC)
        djVC.didMove(toParent: self)
        djVC.view.translatesAutoresizingMaskIntoConstraints = false
        djVC.view.layer.borderColor = UIColor.black.cgColor
        djVC.view.layer.borderWidth = 1.0
    }
    
    override func constructSubviews() {
        view.addSubview(mainStackView)
        view.addSubview(playlistVC.view)
        view.addSubview(djVC.view)
        
        buttonStackView.addArrangedSubview(playPauseButton)
        buttonStackView.addArrangedSubview(jumpToTimeButton)
    
        mainStackView.addArrangedSubview(buttonStackView)
        mainStackView.addArrangedSubview(listenLiveButton)
    }
    
    override func constructConstraints() {
        listenLiveButton.heightAnchor.constraint(equalToConstant: Style.liveButtonHeight).isActive = true
    
        NSLayoutConstraint.activate(
            [djVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             djVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ]
        )

        NSLayoutConstraint.activate(
            [mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )

        NSLayoutConstraint.activate(
            [playlistVC.view.topAnchor.constraint(equalTo: mainStackView.bottomAnchor, constant: Style.playlistViewTopInset),
             playlistVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             playlistVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             playlistVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ]
        )
    }
    
    @objc
    private func playLiveStreamAction(_ sender: UIButton) {
        playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        Player.shared.play(with: retrieveLiveStream())
        
        djVC.currentlyPlayingArchiveShow = nil
        isPlayingArchive = true
        
        djVC.updateShowDetails(fireAnalytic: true) {
            self.removeLoadingIndicator()
        }
        
        playlistVC.livePlaylistShowTime()
        jumpToTimeButton.isHidden = true
        listenLiveButton.isHidden = true
    }
    
    @objc
    private func playPauseAction(_ sender: UIButton) {
        if Player.shared.isPlaying == true {
            Player.shared.pause()
            playPauseButton.setImage(UIImage(named: "playButton"), for: .normal)
            playlistVC.isCurrentlyStreaming = false
        } else if Player.shared.isPlaying == false {
            Player.shared.resume()
            playlistVC.isCurrentlyStreaming = true
            playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        } else {
            playLiveStreamAction(sender)
            playlistVC.isCurrentlyStreaming = true
        }
    }
    
    @objc
    private func archiveStartTimes(_ sender: UIButton) {
        guard let archiveShow = djVC.currentlyPlayingArchiveShow else { return }
        
        let startTimesVC = StartTimesCollectionViewController(archiveShow: archiveShow)
        startTimesVC.startTimesDelegate = self
        startTimesVC.title = "\(archiveShow.show.programName ?? "") with \(archiveShow.show.hostNames?.first ?? "")"
        let navigationController = UINavigationController(rootViewController: startTimesVC)
        navigationController.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: ThemeManager.Archive.Details.Title.font as Any,
             NSAttributedString.Key.foregroundColor: ThemeManager.Archive.Details.Title.textColor]

        show(navigationController, sender: self)
    }
    
    @objc
    private func resetPlaylistIfNeeded() {
       if !isPlayingArchive {
           playlistVC.livePlaylistShowTime()
       }
       
       playlistVC.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
    }

    private func playArchiveShow(archiveShow: ArchiveShow, startTimeDate: Date? = nil) {
        showLoadingIndicator()

        archiveManager.getStreamURLs(for: archiveShow, playbackStartDate: startTimeDate) { [weak self] streamURLs, offset in
            Player.shared.playArchive(with: streamURLs, offset: offset)
            self?.playlistVC.isCurrentlyStreaming = true
            self?.jumpToTimeButton.isHidden = false
            self?.listenLiveButton.isHidden = false
            self?.playlistVC.updateArchievePlaylistShowTime(startTime: startTimeDate ?? archiveShow.show.startTime)
            self?.djVC.currentlyPlayingArchiveShow = archiveShow

            self?.djVC.updateShowDetails(fireAnalytic: true) {
                self?.removeLoadingIndicator()
            }
            
            self?.playPauseButton.setImage(UIImage(named: "pauseButton"), for: .normal)
        }
    }
    
    private func retrieveLiveStream() -> URL? {
        return KEXPPower.availableStreams?.first?.streamURL
    }
    
    private func setupRemoteCommandCenter() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.playCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(playPauseAction(_:)))
    }
}

extension NowPlayingViewController: ArchiveDelegate {
    func playShow(archiveShow: ArchiveShow) {
        isPlayingArchive = true
        playArchiveShow(archiveShow: archiveShow)
    }
}

extension NowPlayingViewController: StartTimesDelegate {
    func playShow(archiveShow: ArchiveShow, archiveShowStart: ArchiveShowStart) {
        playArchiveShow(archiveShow: archiveShow, startTimeDate: archiveShowStart.startTimeDate)
    }
}

extension NowPlayingViewController: PlayerDelegate {
    func handleAudioInterruption() {
        playPauseAction(playPauseButton)
    }
    
    func handlePlaybackError() {
        showAlert(with: "Failed to Play", message: "Check your Internet connection.")
        playPauseAction(playPauseButton)
    }
}
