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
    
    private var nowPlayingStackView: UIStackView = {
        let nowPlayingStackView = UIStackView()
        nowPlayingStackView.axis = .Vertical
        nowPlayingStackView.distribution = .FillEqually
        nowPlayingStackView.translatesAutoresizingMaskIntoConstraints = false
        return nowPlayingStackView
    }()
    
    private var artistLabel: UILabel = {
        let artistLabel = UILabel()
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = UIFont.boldSystemFontOfSize(FontSizes.xsmall)
        artistLabel.numberOfLines = 1
        return artistLabel
    }()
    
    private var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.font = UIFont.italicSystemFontOfSize(FontSizes.xsmall)
        trackLabel.numberOfLines = 1
        return trackLabel
    }()
    
    private var albumLabel: UILabel = {
        let albumLabel = UILabel()
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.font = UIFont.systemFontOfSize(FontSizes.xsmall)
        albumLabel.numberOfLines = 1
        albumLabel.textColor = UIColor.grayColor()
        return albumLabel
    }()
    
    private var timePlayedLabel: UILabel = {
        let timePlayedLabel = UILabel()
        timePlayedLabel.translatesAutoresizingMaskIntoConstraints = false
        timePlayedLabel.font = UIFont.systemFontOfSize(FontSizes.xxsmall)
        timePlayedLabel.numberOfLines = 1
        return timePlayedLabel
    }()
    
    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mma MM/dd/YYYY"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        return dateFormatter
    }()

    private let albumArtImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        focusStyle = .Custom
        contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)

        albumArtImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(nowPlayingStackView)
        contentView.addSubview(albumArtImageView)

        let views = ["albumArtImageView": albumArtImageView, "nowPlayingStackView": nowPlayingStackView]
        let metrics = ["albumArtSize": albumArtSize]
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[albumArtImageView(albumArtSize)]-[nowPlayingStackView]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        nowPlayingStackView.addArrangedSubview(artistLabel)
        nowPlayingStackView.addArrangedSubview(trackLabel)
        nowPlayingStackView.addArrangedSubview(albumLabel)
        nowPlayingStackView.addArrangedSubview(timePlayedLabel)
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[albumArtImageView(albumArtSize)]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-[nowPlayingStackView]-|",
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
    
    func configureNowPlayingCell(song: NowPlaying) {
        artistLabel.text = song.artist
        trackLabel.text = song.songTitle
        albumLabel.text = song.album
        timePlayedLabel.text = dateFormatter.stringFromDate(song.timePlayed)
        albumArtImageView.image = UIImage(named: "vinylPlaceHolder")
    
        if let albumURLString = song.albumArtWork as String? {
            if let albumURL = NSURL(string: albumURLString) {
                albumArtImageView.af_setImageWithURL(albumURL)
            }
        }
    }
}