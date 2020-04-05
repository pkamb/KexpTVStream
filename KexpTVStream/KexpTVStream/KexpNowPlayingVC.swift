//
//  KexpNowPlayingVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import KEXPPower
import Flurry_iOS_SDK

private let nowPlayingTimeInterval:TimeInterval = 15.0
private let currentDJTimeInterval:TimeInterval = 60.0

class KexpNowPlayingVC: UIViewController {
    @IBOutlet var kexpLogo: UIImageView!

    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var djInfoLabel: UILabel!
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumArtworkView: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var albumArtworkButton: ArtworkPlayButton!
    
    private let placeholderImage = UIImage(named: "vinylPlaceHolder")
    
    private let networkManager = NetworkManager()
    
    private var playlistArray = [Play]()
    private var currentSong: Play?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addStyleToView()
        
        UIApplication.shared.isIdleTimerDisabled = UserSettingsManager.disableTimer
        
        networkManager.getConfiguration { [weak self] result in
            guard
                let strongSelf = self,
                case let .success(configuration) = result
            else {
                return
            }

            AudioManager.sharedInstance.configuration = configuration
            AudioManager.sharedInstance.delegate = self
            AudioManager.sharedInstance.setupRemoteCommandCenter()

            strongSelf.loadKexpLogo(configuration?.kexpNowPlayingLogo)
            strongSelf.albumArtworkButton.isEnabled = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(KexpNowPlayingVC.playKexpAction(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.playPause.rawValue as Int)]
        self.view.addGestureRecognizer(tapRecognizer)

        tableView.estimatedRowHeight = 130.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.clear
        tableView.register(KexpPlaylistCell.self, forCellReuseIdentifier: "NowPLayingCell")

        getNowPlayingInfo()
        getCurrentDjInfo()

        Timer.scheduledTimer(timeInterval: nowPlayingTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getNowPlayingInfo), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: currentDJTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getCurrentDjInfo), userInfo: nil, repeats: true)
    }

    private func updateAlbumArtWorkButton(with albumArtUrlString: String?) {
        guard
            let albumArtUrlString = albumArtUrlString
        else {
            albumArtworkButton.setBackgroundImage(placeholderImage, for: .normal)
            return
        }
        
        let albumArtImageView = UIImageView()
        albumArtImageView.fromURLSting(albumArtUrlString, placeHolder: placeholderImage) { albumArtImage in
            self.albumArtworkButton.setBackgroundImage(albumArtImage, for: .normal)
        }
    }

    // MARK: - Networking methods
    
    @objc
    private func getNowPlayingInfo() {
        networkManager.getPlay(limit: 1) { [weak self] result in
            guard
                let strongSelf = self,
                case let .success(playResult) = result,
                let currentSong = playResult?.plays?.first
            else {
                return
            }
            
            let isAirBreak = currentSong.playType == .airbreak

            DispatchQueue.main.async {
//                strongSelf.playlistArray.insert(currentSong, at: 0)
//                strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//
//
                strongSelf.artistLabel.isHidden = isAirBreak
                strongSelf.trackLabel.text = isAirBreak ? "Air Break..." : "Track:"
                strongSelf.albumLabel.isHidden = isAirBreak
                strongSelf.artistNameLabel.isHidden = isAirBreak
                strongSelf.trackNameLabel.isHidden = isAirBreak
                strongSelf.albumNameLabel.isHidden = isAirBreak
                strongSelf.albumArtworkButton.setBackgroundImage(strongSelf.placeholderImage, for: .normal)

                if
                    let lastSongPlayed = strongSelf.currentSong,
                    lastSongPlayed.song != currentSong.song,
                    lastSongPlayed.playType != .airbreak
                {
                    strongSelf.playlistArray.insert(lastSongPlayed, at: 0)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                }
                
                if !isAirBreak {
                    strongSelf.artistNameLabel.text = currentSong.artist
                    strongSelf.trackNameLabel.text = currentSong.song
                    strongSelf.albumNameLabel.text = currentSong.album
                    strongSelf.updateAlbumArtWorkButton(with: currentSong.imageURI)
                }
                
                strongSelf.currentSong = isAirBreak ? nil : currentSong
            }
        }
    }
    
    @objc
    private func getCurrentDjInfo() {
        networkManager.getShow(limit: 1) { [weak self] result in
            guard
                let strongSelf = self,
                case let .success(showResult) = result,
                let show = showResult?.shows?.first,
                case .success = result
            else {
                    return
            }
            
            let onAir = "ON AIR:"
            
            guard let showTitle = show.programName else { strongSelf.djInfoLabel.text = "\(onAir) Unknown"; return }
            guard let djName = show.hostNames?.first else { strongSelf.djInfoLabel.text = "\(onAir) \(showTitle)"; return }

            DispatchQueue.main.async {
                strongSelf.djInfoLabel.text = "\(onAir) " + showTitle + " with " + djName
            }
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func playKexpAction(_ sender: AnyObject) {
        guard
            networkManager.isReachability
        else {
            showAlert("Unable to connect to the Internet")
            setPlayMode(hardStop: true)
            return
        }

        setPlayMode(hardStop: false)
        albumArtworkButton.isSelected = AudioManager.sharedInstance.isPlaying()
    }

    private func showAlert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Whoops!", message: alertMessage, preferredStyle: .alert)

        let alertAction = UIAlertAction.init(title: "OK", style: .default) { [weak self] action in
            guard let strongSelf = self else { return }
            
            strongSelf.setPlayMode(hardStop: true)
            strongSelf.albumArtworkButton.isSelected = false
        }
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setPlayMode(hardStop: Bool, isBackUpStream: Bool = false) {
        if (!AudioManager.sharedInstance.isPlaying() && !hardStop && !isBackUpStream) {
            AudioManager.sharedInstance.play()
            albumArtworkButton.updateState(pause: false)
        }
        else {
            AudioManager.sharedInstance.pause()
            albumArtworkButton.updateState(pause: true)
        }
    }
    
    private func loadKexpLogo(_ logoURL: URL?) {
        kexpLogo.fromURL(logoURL, placeHolder: UIImage(named: "kexp"))
    }
    
    // MARK: - VC Styling
    
    private func addStyleToView() {
        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        kexpLogo.layer.cornerRadius = 30.0
        kexpLogo.clipsToBounds = true
        
        artistNameLabel.text = "-"
        albumNameLabel.text = "-"
        trackNameLabel.text = "-"
        
        let focusGuide = UIFocusGuide()
        view.addLayoutGuide(focusGuide)
        focusGuide.topAnchor.constraint(equalTo: kexpLogo.topAnchor).isActive =  true
        focusGuide.heightAnchor.constraint(equalTo: tableView.heightAnchor).isActive =  true
        focusGuide.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true
        focusGuide.preferredFocusEnvironments = [albumArtworkButton]
    }
}

extension KexpNowPlayingVC: AudioManagerDelegate {
    func audioPlayerDidStartPlaying() {
        getNowPlayingInfo()
    }
    
    func audioPlayerDidStopPlaying(_ hardStop: Bool, backUpStream: Bool) {
        setPlayMode(hardStop: hardStop, isBackUpStream: backUpStream)
    }
    
    func audioPlayerFailedToPlay() {
        showAlert("The KEXP stream is down, please contact KEXP if the issue persists.")
    }
}

extension KexpNowPlayingVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPLayingCell", for: indexPath) as! KexpPlaylistCell
        
        let song = playlistArray[indexPath.row]
        cell.configureNowPlayingCell(song)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = tableView.cellForRow(at: previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        }
        
        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = tableView.cellForRow(at: nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
}
