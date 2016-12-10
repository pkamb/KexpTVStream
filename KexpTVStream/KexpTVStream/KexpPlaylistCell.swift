//
//  KexpPlaylistCell.swift
//  KexpTVStream
//
//  Created by Ryan Garchinsky on 1/12/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import Foundation
import UIKit

private let albumArtSize:CGFloat = 100.0
private let bottomBorderHeight:CGFloat = 1.0

class KexpPlaylistCell: UITableViewCell {
    
    fileprivate var nowPlayingStackView: UIStackView = {
        let nowPlayingStackView = UIStackView()
        nowPlayingStackView.axis = .vertical
        nowPlayingStackView.distribution = .fillEqually
        nowPlayingStackView.translatesAutoresizingMaskIntoConstraints = false
        return nowPlayingStackView
    }()
    
    fileprivate var artistLabel: UILabel = {
        let artistLabel = UILabel()
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = UIFont.boldSystemFont(ofSize: FontSizes.xsmall)
        artistLabel.numberOfLines = 1
        return artistLabel
    }()
    
    fileprivate var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.font = UIFont.italicSystemFont(ofSize: FontSizes.xsmall)
        trackLabel.numberOfLines = 1
        return trackLabel
    }()
    
    fileprivate var albumLabel: UILabel = {
        let albumLabel = UILabel()
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.font = UIFont.systemFont(ofSize: FontSizes.xsmall)
        albumLabel.numberOfLines = 1
        albumLabel.textColor = UIColor.gray
        return albumLabel
    }()
    
    fileprivate var timePlayedLabel: UILabel = {
        let timePlayedLabel = UILabel()
        timePlayedLabel.translatesAutoresizingMaskIntoConstraints = false
        timePlayedLabel.font = UIFont.systemFont(ofSize: FontSizes.xxsmall)
        timePlayedLabel.numberOfLines = 1
        return timePlayedLabel
    }()
    
    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma MM/dd/YYYY"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()

    fileprivate let albumArtImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        focusStyle = .custom
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        albumArtImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nowPlayingStackView)
        contentView.addSubview(albumArtImageView)

        let views = ["albumArtImageView": albumArtImageView, "nowPlayingStackView": nowPlayingStackView] as [String : Any]
        let metrics = ["albumArtSize": albumArtSize]
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[albumArtImageView(albumArtSize)]-[nowPlayingStackView]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        nowPlayingStackView.addArrangedSubview(artistLabel)
        nowPlayingStackView.addArrangedSubview(trackLabel)
        nowPlayingStackView.addArrangedSubview(albumLabel)
        nowPlayingStackView.addArrangedSubview(timePlayedLabel)
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[albumArtImageView(albumArtSize)]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[nowPlayingStackView]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        assertionFailure("Not implemented!")
    }
    
    func configureNowPlayingCell(_ song: NowPlaying) {
        artistLabel.text = song.artist
        trackLabel.text = song.songTitle
        albumLabel.text = song.album
        timePlayedLabel.text = dateFormatter.string(from: song.timePlayed as Date)
        albumArtImageView.image = UIImage(named: "vinylPlaceHolder")
    
        if let albumURLString = song.albumArtWork as String? {
            if let albumURL = URL(string: albumURLString) {
                albumArtImageView.af_setImage(withURL: albumURL, placeholderImage: nil, filter: nil)
            }
        }
    }
}
