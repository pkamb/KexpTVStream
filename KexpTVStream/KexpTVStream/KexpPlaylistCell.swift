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
        
        let bottomBorder = UIView()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        albumArtImageView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorder.backgroundColor = UIColor.grayColor()
        
        contentView.addSubview(artistLabel)
        contentView.addSubview(trackLabel)
        contentView.addSubview(albumArtImageView)
        contentView.addSubview(albumLabel)
        contentView.addSubview(timePlayedLabel)
        contentView.addSubview(bottomBorder)

        let views = ["artistLabel": artistLabel, "albumArtImageView": albumArtImageView, "trackLabel": trackLabel, "albumLabel": albumLabel, "timePlayedLabel": timePlayedLabel, "bottomBorder": bottomBorder]
        let metrics = ["albumArtSize": albumArtSize, "bottomBorderHeight": bottomBorderHeight]
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[albumArtImageView(albumArtSize)]-[artistLabel]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[albumArtImageView(albumArtSize)]-[trackLabel]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[albumArtImageView(albumArtSize)]-[albumLabel]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-[albumArtImageView(albumArtSize)]-[timePlayedLabel]-|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[bottomBorder]|",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
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
                "V:|-[artistLabel][trackLabel][albumLabel][timePlayedLabel]",
                options: [],
                metrics:metrics,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[bottomBorder(bottomBorderHeight)]|",
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
            if let albumURL = NSURL.init(string: albumURLString) {
                albumArtImageView.af_setImageWithURL(albumURL)
            }
        }
    }
}