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

        KexpController.getKEXPConfig {[weak self] (kexpConfig) -> Void in
            KexpAudioManager.setup(kexpConfig)
            KexpAudioManager.sharedInstance.delegate = self
            KexpAudioManager.sharedInstance.setupRemoteCommandCenter()

            self!.loadKexpLogo(kexpConfig.nowPlayingLogo)
            self!.playPauseButton.enabled = true
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "playKexpAction:")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)];
        self.view.addGestureRecognizer(tapRecognizer)
        
        artistNameLabel.text = "-"
        albumNameLabel.text = "-"
        trackNameLabel.text = "-"
        
        getNowPlayingInfo()
        getCurrentDjInfo()
        
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "getNowPlayingInfo", userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "getCurrentDjInfo", userInfo: nil, repeats: true)
    }

    private func updateAlbumArtWork(albumArtUrl: String) {
        if let albumArt =  NSURL(string: albumArtUrl) {
            albumArtworkView.af_setImageWithURL(
                albumArt,
                placeholderImage: nil
            )
        }
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
        KexpController.getNowPlayingInfo({ [weak self] (nowPlaying) -> Void in
            if (nowPlaying.airBreak) {
                self!.artistLabel.hidden = true
                self!.trackLabel.text = "Air Break..."
                self!.albumLabel.hidden = true
                self!.artistNameLabel.hidden = true
                self!.trackNameLabel.hidden = true
                self!.albumNameLabel.hidden = true
                self!.albumArtworkView.image = UIImage.init(named: "vinylPlaceHolder")
            }
            else {
                self!.artistLabel.hidden = false
                self!.trackLabel.hidden = false
                self!.albumLabel.hidden = false
                self!.artistNameLabel.hidden = false
                self!.trackNameLabel.hidden = false
                self!.albumNameLabel.hidden = false
                
                self!.artistNameLabel.text = nowPlaying.artist
                self!.trackNameLabel.text = nowPlaying.songTitle
                self!.albumNameLabel.text = nowPlaying.album
                
                if let albumArtUrl = nowPlaying.albumArtWork {
                    self!.updateAlbumArtWork(albumArtUrl)
                }
                else {
                   self!.albumArtworkView.image = UIImage(named: "vinylPlaceHolder")
                }
                
                if (self!.playlistArray.count == 0) {
                    self!.playlistArray.addObject(nowPlaying)

                    self!.tableView.reloadData()
                }
                else if let lastItemAdded = self!.playlistArray[0] as? NowPlaying {
                    if ((nowPlaying.artist != lastItemAdded.artist) && (nowPlaying.songTitle != lastItemAdded.songTitle)) {
                        self!.playlistArray.insertObject(nowPlaying, atIndex: 0)
                        self!.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func getCurrentDjInfo() {
        KexpController.getDjInfo { [unowned self] (currentDjInfo) -> Void in
            if let showTitle = currentDjInfo.showTitle, djName = currentDjInfo.djName {
                self.djInfoLabel.text = "ON NOW: " + showTitle + " with " + djName
            }
            else {
                self.djInfoLabel.text = "ON NOW: UNKNOWN"
            }
        }
    }
    
    // MARK: - @IBAction
    @IBAction func playKexpAction(sender: AnyObject) {
        if (playPauseButton.selected) && !InternetReachability.isConnectedToNetwork() {
            showAlert("Unable to connect to the Internet")
            
            return;
        }
        
        setPlayMode()
        
        playPauseButton.selected = KexpAudioManager.sharedInstance.isPlaying()
    }
    
    private func showAlert(alertMessage: String) {
        let alert = UIAlertController(title: "Whoops!", message: alertMessage, preferredStyle: .Alert)
        let alertAction = UIAlertAction(title: "OK", style: .Default, handler:nil)
        
        alert.addAction(alertAction)
        self .presentViewController(alert, animated: true, completion: nil)
        
        return;
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
        guard let imageUrl = logoUrl as String? else { return }
        if let logo =  NSURL(string: imageUrl) {
            kexpLogo.af_setImageWithURL(
                logo,
                placeholderImage: UIImage.init(named: "kexp")
            )
        }
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
    }
    
    // MARK: - UITableView Datasource/Delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        
        if let item = playlistArray[indexPath.row] as? NowPlaying {
            cell.textLabel?.text = item.artist
            cell.detailTextLabel?.text = item.songTitle
        }
        
        return cell
    }
}
