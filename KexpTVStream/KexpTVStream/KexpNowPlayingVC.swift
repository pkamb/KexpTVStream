//
//  KexpNowPlayingVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AlamofireImage

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
    
    var playlistArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStyleToView()

        KexpController.getKEXPConfig { [weak self] (kexpConfig) -> Void in
            guard let strongSelf = self else { return }
            
            KexpAudioManager.setup(kexpConfig)
            KexpAudioManager.sharedInstance.delegate = self
            KexpAudioManager.sharedInstance.setupRemoteCommandCenter()

            strongSelf.loadKexpLogo(kexpConfig.nowPlayingLogo)
            strongSelf.playPauseButton.enabled = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(KexpNowPlayingVC.playKexpAction(_:)))
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        tableView.estimatedRowHeight = 130.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(KexpPlaylistCell.self, forCellReuseIdentifier: "NowPLayingCell")
        
        getNowPlayingInfo()
        getCurrentDjInfo()

        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(KexpNowPlayingVC.getNowPlayingInfo), userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(KexpNowPlayingVC.getCurrentDjInfo), userInfo: nil, repeats: true)
    }

    private func updateAlbumArtWork(albumArtUrl: String?) {
        guard let albumUrlString = albumArtUrl else { albumArtworkView.image = UIImage(named: "vinylPlaceHolder"); return }
        guard let albumArtUrl = NSURL(string: albumUrlString) else { albumArtworkView.image = UIImage(named: "vinylPlaceHolder"); return }

        albumArtworkView.af_setImageWithURL( albumArtUrl, placeholderImage: UIImage(named: "vinylPlaceHolder"))
    }
    
    // MARK: - KexpAudioManagerDelegate Methods
    func kexpAudioPlayerDidStartPlaying() {
        UIApplication.sharedApplication().idleTimerDisabled = true
        getNowPlayingInfo()
    }
    
    func kexpAudioPlayerDidStopPlaying() {
        UIApplication.sharedApplication().idleTimerDisabled = false
        setPlayMode()
    }
    
    func kexpAudioPlayerFailedToPlay() {
        showAlert("The KEXP stream is down, please contact KEXP if the issue persists.")
    }
    
    // MARK: - Networking methods
    func getNowPlayingInfo() {
        KexpController.getNowPlayingInfo({ [weak self] nowPlaying -> Void in
            guard let strongSelf = self else { return }
            guard let nowPlaying = nowPlaying else { return }

            if nowPlaying.airBreak {
                strongSelf.artistLabel.hidden = true
                strongSelf.trackLabel.text = "Air Break..."
                strongSelf.albumLabel.hidden = true
                strongSelf.artistNameLabel.hidden = true
                strongSelf.trackNameLabel.hidden = true
                strongSelf.albumNameLabel.hidden = true
                strongSelf.albumArtworkView.image = UIImage(named: "vinylPlaceHolder")
            }
            else {
                strongSelf.trackLabel.text = "Track:"
                strongSelf.artistLabel.hidden = false
                strongSelf.trackLabel.hidden = false
                strongSelf.albumLabel.hidden = false
                strongSelf.artistNameLabel.hidden = false
                strongSelf.trackNameLabel.hidden = false
                strongSelf.albumNameLabel.hidden = false
                
                strongSelf.artistNameLabel.text = nowPlaying.artist
                strongSelf.trackNameLabel.text = nowPlaying.songTitle
                strongSelf.albumNameLabel.text = nowPlaying.album
                
                strongSelf.updateAlbumArtWork(nowPlaying.albumArtWork)
                
                if (strongSelf.playlistArray.count == 0) {
                    strongSelf.playlistArray.addObject(nowPlaying)

                    strongSelf.tableView.reloadData()
                }
                else if let lastItemAdded = strongSelf.playlistArray.firstObject as? NowPlaying {
                    if nowPlaying.playId != lastItemAdded.playId {
                        strongSelf.playlistArray.insertObject(nowPlaying, atIndex: 0)
                        strongSelf.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
                    }
                }
            }
        })
    }
    
    func getCurrentDjInfo() {
        KexpController.getDjInfo { [weak self] currentDjInfo -> Void in
            guard let strongSelf = self else { return }
            guard let currentDjInfo = currentDjInfo else { return }
            guard let showTitle = currentDjInfo.showTitle else { strongSelf.djInfoLabel.text = "ON NOW: Unknown"; return }
            guard let djName = currentDjInfo.djName else { strongSelf.djInfoLabel.text = "ON NOW: \(showTitle)"; return }
    
            strongSelf.djInfoLabel.text = "ON NOW: " + showTitle + " with " + djName
        }
    }
    
    // MARK: - @IBAction
    @IBAction func playKexpAction(sender: AnyObject) {
        if playPauseButton.selected && !InternetReachability.isConnectedToNetwork() {
            showAlert("Unable to connect to the Internet")
        }
        else {
            setPlayMode()
            playPauseButton.selected = KexpAudioManager.sharedInstance.isPlaying()
        }
    }
    
    private func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Whoops!", message: alertMessage, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
        
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func setPlayMode() {
        if (!KexpAudioManager.sharedInstance.isPlaying()) {
            playPauseButton.setImage(UIImage(named: "pauseButton"), forState: .Normal)
            KexpAudioManager.sharedInstance.play()
        }
        else {
            playPauseButton.setImage(UIImage(named: "playButton"), forState: .Normal)
            KexpAudioManager.sharedInstance.pause()
        }
    }
    
    private func loadKexpLogo(logoUrl: String?) {
        guard let imageUrlString = logoUrl as String? else { kexpLogo.image = UIImage(named: "kexp"); return }
        guard let imageUrl = NSURL(string: imageUrlString) else { kexpLogo.image = UIImage(named: "kexp"); return }

        kexpLogo.af_setImageWithURL(imageUrl, placeholderImage: UIImage(named: "kexp"))
    }
    
    // MARK: - VC Styling
    private func addStyleToView() {
        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, atIndex: 0)
        
        kexpLogo.layer.cornerRadius = 30.0
        kexpLogo.clipsToBounds = true
        
        albumArtworkView.layer.cornerRadius = 30.0
        albumArtworkView.clipsToBounds = true
        
        artistNameLabel.text = "-"
        albumNameLabel.text = "-"
        trackNameLabel.text = "-"
    }
    
    // MARK: - UITableView Datasource/Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NowPLayingCell", forIndexPath: indexPath) as! KexpPlaylistCell
        
        if let songNowPlaying = playlistArray[indexPath.row] as? NowPlaying {
            cell.configureNowPlayingCell(songNowPlaying)
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didUpdateFocusInContext context: UITableViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = tableView.cellForRowAtIndexPath(previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        }
        
        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = tableView.cellForRowAtIndexPath(nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        }
    }
}
