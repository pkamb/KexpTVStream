//
//  AudioManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/20/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AVKit
import KEXPPower

protocol AudioManagerDelegate: class {
    func audioPlayerDidStartPlaying()
    func audioPlayerDidStopPlaying(_ hardStop: Bool, backUpStream: Bool)
    func audioPlayerFailedToPlay()
}

class AudioManager: NSObject {
    static let sharedInstance : AudioManager = {
            return AudioManager()
        }()

    var configuration: Configuration? {
        didSet {
           currentStreamURL = configuration?.kexpStreamUrl
        }
    }
    
    var audioPlayerItem: AVPlayerItem?
    var audioPlayer: AVPlayer?
    var currentStreamURL: URL?
    
    weak var delegate: AudioManagerDelegate?

    deinit {
        deInitStream()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initStream() {
        guard let streamURL = currentStreamURL else { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AudioManager.handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AudioManager.handleInterruption(_:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        
        if audioPlayerItem != nil {
            deInitStream()
        }

        audioPlayerItem = AVPlayerItem(url: streamURL)
        audioPlayerItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        audioPlayerItem?.addObserver(self, forKeyPath: "timedMetadata", options: .new, context: nil)

        if let audioPlayerItem = audioPlayerItem {
            audioPlayer = AVPlayer(playerItem: audioPlayerItem)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
        }
    }
    
    private func deInitStream() {
        audioPlayerItem?.removeObserver(self, forKeyPath: "status")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        audioPlayerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        audioPlayerItem?.removeObserver(self, forKeyPath: "timedMetadata")
        
        audioPlayer = nil
        audioPlayerItem = nil
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
        guard let audioRate = audioPlayer?.rate else { return false }
        return Double(audioRate) > 0.0 && audioPlayer?.error == nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        guard let delegate = delegate else { return }
        guard let configuration = configuration else { return }

        if keyPath == "status" {
            if playerItem.status == .readyToPlay {
                delegate.audioPlayerDidStartPlaying()
                currentStreamURL = configuration.kexpStreamUrl
            }
            else if playerItem.status == .failed {
                deInitStream()
                
                let isStreamingFromBackup = currentStreamURL?.absoluteString == configuration.kexpBackupStreamUrl.absoluteString
                delegate.audioPlayerDidStopPlaying(false, backUpStream: isStreamingFromBackup)

                if isStreamingFromBackup {
                    delegate.audioPlayerFailedToPlay()
                } else {
                    currentStreamURL = configuration.kexpBackupStreamUrl
                }
            }
        }
    }
    
    func setupRemoteCommandCenter() {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        
        remoteCommandCenter.pauseCommand.isEnabled = true
        remoteCommandCenter.pauseCommand.addTarget(self, action: #selector(AudioManager.pauseEvent))
    }
    
    @objc func pauseEvent() {
        delegate?.audioPlayerDidStopPlaying(false, backUpStream: false)
        pause()
    }
    
    // MARK: - NSNotification
    // This is called when audio is taken from another app. Sending a HardStop when an AVAudioSessionInterruptionType is fired
    @objc func handleInterruption(_ notification: Notification) {
        guard let interruptionTypeUInt = (notification as NSNotification).userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeUInt) {
            if interruptionType == .began || interruptionType == .ended {
                pause()
                delegate?.audioPlayerDidStopPlaying(true, backUpStream: false)
            }
        }
    }
    
    func updateNowPlaying(play: Play) {
        let trackName = play.track?.name
        let artistName = play.artist?.name
        let albumName = play.release?.name

        if let artistName = artistName {
            let artistNameItem = AVMutableMetadataItem()
            artistNameItem.identifier = .commonIdentifierArtist
            artistNameItem.locale = .current
            artistNameItem.value = artistName as NSString
            artistNameItem.keySpace = AVMetadataKeySpace.common
            
            audioPlayerItem?.externalMetadata.append(artistNameItem)
        }
        
        if let trackName = trackName {
            let trackItem = AVMutableMetadataItem()
            trackItem.identifier = .commonIdentifierTitle
            trackItem.locale = .current
            trackItem.value = trackName as NSString
            trackItem.keySpace = .common
            
            audioPlayerItem?.externalMetadata.append(trackItem)
        }

        if let albumName = albumName {
            let albumNameItem = AVMutableMetadataItem()
            albumNameItem.identifier = .commonIdentifierAlbumName
            albumNameItem.locale = .current
            albumNameItem.value = albumName as NSString
            albumNameItem.keySpace = .common
            
            audioPlayerItem?.externalMetadata.append(albumNameItem)
        }

        let artworkMetadataItem = AVMutableMetadataItem()
        artworkMetadataItem.locale = .current
        artworkMetadataItem.identifier = .commonIdentifierArtwork

        if let albumArtUrl = play.release?.largeImageURL {
            let albumArtImageView = UIImageView()
            
            albumArtImageView.fromURL(albumArtUrl) { albumArtImage in
                guard let albumArtImage = albumArtImage else { return }
                
                artworkMetadataItem.value = albumArtImage as? NSCopying & NSObjectProtocol
                self.audioPlayerItem?.externalMetadata.append(artworkMetadataItem)
                self.loadNowPlayingInfo(artistName: artistName, trackName: trackName, artWork: albumArtImage)
            }
        } else {
            guard let placeHolderAlbumArt = UIImage(named: "vinylPlaceHolder") else { return }

            artworkMetadataItem.value = placeHolderAlbumArt as? NSCopying & NSObjectProtocol
            audioPlayerItem?.externalMetadata.append(artworkMetadataItem)
        }
    }
    
    private func loadNowPlayingInfo(artistName: String?, trackName: String?, artWork: UIImage) {
        var nowPlayingInfo = [String: Any]()
        
        if let artistName = artistName {
            nowPlayingInfo[MPMediaItemPropertyArtist] = artistName
        }
        
        if let trackName = trackName {
            nowPlayingInfo[MPMediaItemPropertyTitle] = trackName
        }
        
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artWork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
