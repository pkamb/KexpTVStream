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
    func kexpAudioPlayerDidStopPlaying(hardStop: Bool)
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
        currentKexpUrlString = kexpConfigSettings.streamUrl
    }
    
    var audioPlayerItem: AVPlayerItem?
    var audioPlayer: AVPlayer?
    
    var currentKexpUrlString: String?
    
    var delegate: KexpAudioManagerDelegate?
    
    override init() {
        super.init()
    }
    
    deinit {
        deInitStream()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func initStream() {
        guard let currentKexpUrlString = currentKexpUrlString else { return }
        guard let streamURL = NSURL(string: currentKexpUrlString) else { return }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(KexpAudioManager.handleInterruption(_:)), name: AVAudioSessionInterruptionNotification, object: nil)
        
        if audioPlayerItem != nil {
            deInitStream()
        }

        audioPlayerItem = AVPlayerItem(URL: streamURL)
        audioPlayerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .New, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .New, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .New, context: nil)
        
        if let audioPlayerItem = audioPlayerItem {
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
            
            _ = try? AVAudioSession.sharedInstance().setActive(true)
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
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
        return audioPlayer?.rate > 0 && audioPlayer?.error == nil
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let playerItem = object as? AVPlayerItem else { return }
        guard let delegate = delegate else { return }
        guard let kexpConfig = kexpConfig else { return }

        if keyPath == "status" {
            if playerItem.status == .ReadyToPlay {
                delegate.kexpAudioPlayerDidStartPlaying()
                currentKexpUrlString = kexpConfig.streamUrl
            }
            else if playerItem.status == .Failed {
                deInitStream()
                delegate.kexpAudioPlayerDidStopPlaying(false)
                
                if currentKexpUrlString == kexpConfig.backupStreamUrl {
                    delegate.kexpAudioPlayerFailedToPlay()
                } else {
                    currentKexpUrlString = kexpConfig.backupStreamUrl
                }
            }
        }
        else if keyPath == "playbackBufferEmpty" {
            pause()
            deInitStream()
            delegate.kexpAudioPlayerDidStopPlaying(false)
        }
    }
    
    func setupRemoteCommandCenter() {
        let remoteCommandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        
        remoteCommandCenter.pauseCommand.enabled = true
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(KexpAudioManager.pauseEvent))
    }
    
    func pauseEvent() {
        delegate?.kexpAudioPlayerDidStopPlaying(false)
        pause()
    }
    
    // MARK: - NSNotification
    // This is called when audio is taken from another app. Sending a HardStop when an AVAudioSessionInterruptionType is fired
    func handleInterruption(notification: NSNotification) {
        guard let interruptionTypeUInt = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeUInt) {
            if interruptionType == .Began || interruptionType == .Ended {
                pause()
                delegate?.kexpAudioPlayerDidStopPlaying(true)
            }
        }
    }
}