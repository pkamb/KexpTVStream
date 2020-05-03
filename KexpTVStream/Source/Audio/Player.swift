//
//  Player.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/2/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import AVFoundation

class Player {
    static let sharedInstance = Player()
    private init(){}
    
    var player = AVPlayer()
    private var playerItem: AVPlayerItem?
}
