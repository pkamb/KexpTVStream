//
//  Player.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/2/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import AVFoundation
import KEXPPower

class Player {
    static let sharedInstance = Player()
    private init(){}

    //`nil` means nothing has been played
    var isPlaying: Bool?
    
    private var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var currentStreamURL: URL?
    private var archiveStreamURLs = [URL]()
    
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
}
