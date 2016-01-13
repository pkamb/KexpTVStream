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

private let kexpStreamUrl = "http://live-aacplus-64.kexp.org/kexp64.aac"
private let kexpBackupStreamUrl = "http://live-mp3-128.kexp.org:8000/listen.pls"

protocol KexpAudioManagerDelegate {
    func kexpAudioPlayerDidStartPlaying()
    func kexpAudioPlayerDidStopPlaying()
    func kexpAudioPlayerFailedToPlay()
}

class KexpAudioManager: NSObject {
    static let sharedInstance = KexpAudioManager()
    
    var audioPlayerItem: AVPlayerItem?
    var audioPlayer: AVPlayer?
    
    var currentKexp = kexpStreamUrl
    
    var delegate: KexpAudioManagerDelegate?

    override init() {
        super.init()
    }
    
    private func initStream() {
        if let streamURL = NSURL(string: currentKexp) {
            audioPlayerItem = AVPlayerItem(URL: streamURL)
            audioPlayerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
            audioPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
            audioPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
            audioPlayerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .New, context: nil)

            audioPlayer = AVPlayer(playerItem: audioPlayerItem!)

            try! AVAudioSession.sharedInstance().setActive(true)
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
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
                    currentKexp = kexpStreamUrl
                }
                else if (playerItem.status == .Failed) {
                    deInitStream()
                    delegate?.kexpAudioPlayerDidStopPlaying()
                    
                    if (currentKexp == kexpBackupStreamUrl) {
                       delegate?.kexpAudioPlayerFailedToPlay()
                    } else {
                        currentKexp = kexpBackupStreamUrl
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
        pauseCommand.addTarget(self, action: "pauseEvent")
    }
    
    func pauseEvent() {
        delegate?.kexpAudioPlayerDidStopPlaying()
        pause()
    }
}
