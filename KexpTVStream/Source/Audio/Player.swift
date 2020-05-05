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

    var isPlaying = false
    
    private var player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var currentStreamURL: URL?
    
    func play(with playUrl: URL?) {
        guard let playUrl = playUrl else { return }
        
        player.cancelPendingPrerolls()
        playerItem = AVPlayerItem(url: playUrl)
        player.replaceCurrentItem(with: playerItem)
        isPlaying = true

        player.play()
    }
    
    func pause() {
        isPlaying = false
        player.pause()
    }
}
