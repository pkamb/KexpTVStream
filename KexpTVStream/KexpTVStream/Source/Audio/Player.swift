//
//  Player.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/2/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import AVFoundation
import KEXPPower

protocol PlayerDelegate: class {
    func handleAudioInterruption()
    func handlePlaybackError()
}

class Player: NSObject {
    static let shared = Player()

    //`nil` means nothing has been played
    var isPlaying: Bool?
    
    private var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var currentStreamURL: URL?
    private var archiveStreamURLs = [URL]()
    
    weak var delegate: PlayerDelegate?
    
    private override init() {
        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlaybackError), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)

    }
    
    func play(with playUrl: URL?) {
        guard let playUrl = playUrl else { return }
        
        archiveStreamURLs.removeAll()
        player.cancelPendingPrerolls()
        playerItem = AVPlayerItem(url: playUrl)
        player.replaceCurrentItem(with: playerItem)
        isPlaying = true

        player.play()
    }
    
    func playArchive(with playUrls: [URL], offset: Double) {
        archiveStreamURLs.removeAll()
        archiveStreamURLs = playUrls
        
        player.pause()

        if let startUrl = playUrls.first {
            playerItem = AVPlayerItem(url: startUrl)
            player.replaceCurrentItem(with: playerItem)
            archiveStreamURLs.remove(at: 0)
        }

        player.seek(to: CMTime(seconds: offset, preferredTimescale: 1))
        isPlaying = true

        player.play()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
    }
    
    func resume() {
        isPlaying = true
        player.play()
    }

    // MARK: - NSNotification
    // This is called when audio is taken from another app. Sending a HardStop when an AVAudioSessionInterruptionType is fired
    @objc
    private func handleInterruption(_ notification: Notification) {
        guard let interruptionTypeUInt = (notification as NSNotification).userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt),
            interruptionType == .began
        {
            delegate?.handleAudioInterruption()
        }
    }
    
    @objc
    private func handlePlaybackError() {
        delegate?.handlePlaybackError()
    }
}
