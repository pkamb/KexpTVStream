//
//  KexpNowPlayingVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AlamofireImage

private let nowPlayingTimeInterval:TimeInterval = 15.0
private let currentDJTimeInterval:TimeInterval = 60.0

class KexpNowPlayingVC: UIViewController, KexpAudioManagerDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var kexpLogo: UIImageView!

    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var trackLabel: UILabel!
    @IBOutlet var albumLabel: UILabel!
    @IBOutlet var djInfoLabel: UILabel!
    
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var trackNameLabel: UILabel!
    @IBOutlet var albumNameLabel: UILabel!
    @IBOutlet var albumArtworkView: UIImageView!
    @IBOutlet var tableView: UITableView!
    
    var playlistArray = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStyleToView()

        KexpController.getConfig { [weak self] (kexpConfig) -> Void in
            guard let strongSelf = self else { return }

            KexpAudioManager.sharedInstance.kexpConfig = kexpConfig
            KexpAudioManager.sharedInstance.delegate = self
            KexpAudioManager.sharedInstance.setupRemoteCommandCenter()

            strongSelf.loadKexpLogo(kexpConfig.nowPlayingLogo)
            strongSelf.playPauseButton.isEnabled = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(KexpNowPlayingVC.playKexpAction(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(value: UIPressType.playPause.rawValue as Int)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        tableView.estimatedRowHeight = 130.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.clear
        tableView.register(KexpPlaylistCell.self, forCellReuseIdentifier: "NowPLayingCell")
        
        getNowPlayingInfo()
        getCurrentDjInfo()

        Timer.scheduledTimer(timeInterval: nowPlayingTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getNowPlayingInfo), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: currentDJTimeInterval, target: self, selector: #selector(KexpNowPlayingVC.getCurrentDjInfo), userInfo: nil, repeats: true)
    }

    func updateAlbumArtWork(_ albumArtUrl: URL?) {
        guard let albumArtUrl = albumArtUrl else { albumArtworkView.image = UIImage(named: "vinylPlaceHolder"); return }
        
        albumArtworkView.af_setImage(
            withURL: albumArtUrl,
            placeholderImage: UIImage(named: "vinylPlaceHolder"),
            filter: nil
        )
    }
    
    // MARK: - KexpAudioManagerDelegate Methods
    func kexpAudioPlayerDidStartPlaying() {
        UIApplication.shared.isIdleTimerDisabled = true
        getNowPlayingInfo()
    }
    
    func kexpAudioPlayerDidStopPlaying(_ hardStop: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        setPlayMode(hardStop)
    }
    
    func kexpAudioPlayerFailedToPlay() {
        showAlert("The KEXP stream is down, please contact KEXP if the issue persists.")
    }
    
    // MARK: - Networking methods
    func getNowPlayingInfo() {
        KexpController.getSong({ [weak self] song -> Void in
            guard let strongSelf = self else { return }
            guard let song = song else { return }

            if song.playTypeId == 4 {
                strongSelf.artistLabel.isHidden = true
                strongSelf.trackLabel.text = "Air Break..."
                strongSelf.albumLabel.isHidden = true
                strongSelf.artistNameLabel.isHidden = true
                strongSelf.trackNameLabel.isHidden = true
                strongSelf.albumNameLabel.isHidden = true
                strongSelf.albumArtworkView.image = UIImage(named: "vinylPlaceHolder")
            }
            else {
                strongSelf.trackLabel.text = "Track:"
                strongSelf.artistLabel.isHidden = false
                strongSelf.trackLabel.isHidden = false
                strongSelf.albumLabel.isHidden = false
                strongSelf.artistNameLabel.isHidden = false
                strongSelf.trackNameLabel.isHidden = false
                strongSelf.albumNameLabel.isHidden = false
                
                strongSelf.artistNameLabel.text = song.artistName
                strongSelf.trackNameLabel.text = song.trackName
                strongSelf.albumNameLabel.text = song.releaseName
                
                strongSelf.updateAlbumArtWork(song.largeImageUrl)
                
                if (strongSelf.playlistArray.count == 0) {
                    strongSelf.playlistArray.append(song)

                    strongSelf.tableView.reloadData()
                }
                else if let lastItemAdded = strongSelf.playlistArray.first {
                    if song.playId != lastItemAdded.playId, song.playTypeId != 4 {
                        strongSelf.playlistArray.insert(song, at: 0)
                        strongSelf.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    }
                }
            }
        })
    }
    
    func getCurrentDjInfo() {
        KexpController.getShow { [weak self] show -> Void in
            guard let strongSelf = self else { return }
            guard let show = show else { return }
            guard let showTitle = show.showName else { strongSelf.djInfoLabel.text = "ON NOW: Unknown"; return }
            guard let djName = show.hosts?.first?.hostName else { strongSelf.djInfoLabel.text = "ON NOW: \(showTitle)"; return }
    
            strongSelf.djInfoLabel.text = "ON NOW: " + showTitle + " with " + djName
        }
    }
    
    // MARK: - @IBAction
    @IBAction func playKexpAction(_ sender: AnyObject) {
        if playPauseButton.isSelected && !InternetReachability.isConnectedToNetwork() {
            showAlert("Unable to connect to the Internet")
        }
        else {
            setPlayMode(false)
            playPauseButton.isSelected = KexpAudioManager.sharedInstance.isPlaying()
        }
    }
    
    fileprivate func showAlert(_ alertMessage: String) {
        let alert = UIAlertController(title: "Whoops!", message: alertMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler:nil)
        
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    fileprivate func setPlayMode(_ hardStop: Bool) {
        if (!KexpAudioManager.sharedInstance.isPlaying() && !hardStop) {
            playPauseButton.setImage(UIImage(named: "pauseButton"), for: UIControlState())
            KexpAudioManager.sharedInstance.play()
        }
        else {
            playPauseButton.setImage(UIImage(named: "playButton"), for: UIControlState())
            KexpAudioManager.sharedInstance.pause()
        }
    }
    
    fileprivate func loadKexpLogo(_ logoUrl: String?) {
        guard let imageUrlString = logoUrl as String? else { kexpLogo.image = UIImage(named: "kexp"); return }
        guard let imageUrl = URL(string: imageUrlString) else { kexpLogo.image = UIImage(named: "kexp"); return }

        kexpLogo.af_setImage(withURL: imageUrl, placeholderImage: UIImage(named: "kexp"), filter: nil)
    }
    
    // MARK: - VC Styling
    fileprivate func addStyleToView() {
        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        kexpLogo.layer.cornerRadius = 30.0
        kexpLogo.clipsToBounds = true
        
        albumArtworkView.layer.cornerRadius = 30.0
        albumArtworkView.clipsToBounds = true
        
        artistNameLabel.text = "-"
        albumNameLabel.text = "-"
        trackNameLabel.text = "-"
    }
    
    // MARK: - UITableView Datasource/Delegate
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
