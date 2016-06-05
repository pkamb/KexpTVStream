//
//  KexpAudioManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/20/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol KexpAudioManagerDelegate {
    func kexpAudioPlayerDidStartPlaying()
    func kexpAudioPlayerDidStopPlaying()
    func kexpAudioPlayerFailedToPlay()
}

class KexpAudioManager: NSObject {
    static var sharedInstance = KexpAudioManager()
    private var kexpConfig: KexpConfigSettings?
    
    class func setup(config: KexpConfigSettings) -> KexpAudioManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
        }
        dispatch_once(&Static.onceToken) {
            sharedInstance = KexpAudioManager(kexpConfigSettings: config)
        }

        return sharedInstance
    }
    
    init(kexpConfigSettings: KexpConfigSettings) {
        self.kexpConfig = kexpConfigSettings
        currentKexp = kexpConfigSettings.streamUrl
    }
    
    var audioPlayerItem: AVPlayerItem?
    var audioPlayer: AVPlayer?
    
    var currentKexp: String?
    
    var delegate: KexpAudioManagerDelegate?
    
    override init() {
        super.init()
    }
    
    private func initStream() {
        if let currentKexp = currentKexp {
            if let streamURL = NSURL(string: currentKexp) {
                audioPlayerItem = AVPlayerItem(URL: streamURL)
                audioPlayerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
                audioPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
                audioPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
                audioPlayerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .New, context: nil)
                
                if let audioPlayerItem = audioPlayerItem {
                    audioPlayer = AVPlayer(playerItem: audioPlayerItem)
                    
                    try! AVAudioSession.sharedInstance().setActive(true)
                    try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
                }
            }
        }
    }
    
    private func deInitStream() {
        audioPlayerItem?.removeObserver(self, forKeyPath: "status")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        audioPlayerItem?.removeObserver(self, forKeyPath: "timedMetadata")
        
        audioPlayer = nil;
        audioPlayerItem = nil;
    }
    
    func play() {
        initStream()
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
        deInitStream()
    }
    
    func isPlaying() -> Bool {
        return ((audioPlayer?.rate > 0) && (audioPlayer?.error == nil))
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let playerItem = object as? AVPlayerItem {
            if (keyPath == "status") {
                if (playerItem.status == .ReadyToPlay) {
                    delegate?.kexpAudioPlayerDidStartPlaying()
                    currentKexp = kexpConfig?.streamUrl
                }
                else if (playerItem.status == .Failed) {
                    deInitStream()
                    delegate?.kexpAudioPlayerDidStopPlaying()
                    
                    if (currentKexp == kexpConfig?.backupStreamUrl) {
                        delegate?.kexpAudioPlayerFailedToPlay()
                    } else {
                        currentKexp = kexpConfig?.backupStreamUrl
                    }
                }
            }
            else if (keyPath == "playbackBufferEmpty") {
                pause()
                deInitStream()
                delegate?.kexpAudioPlayerDidStopPlaying()
            }
        }
    }
    
    func setupRemoteCommandCenter() {
        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        let pauseCommand = remoteCommandCenter.pauseCommand
        pauseCommand.enabled = true
        pauseCommand.addTarget(self, action: #selector(KexpAudioManager.pauseEvent))
    }
    
    func pauseEvent() {
        delegate?.kexpAudioPlayerDidStopPlaying()
        pause()
    }
}