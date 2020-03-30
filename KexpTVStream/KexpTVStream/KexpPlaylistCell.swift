//
//  KexpPlaylistCell.swift
//  KexpTVStream
//
//  Created by Ryan Garchinsky on 1/12/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import KEXPPower
import UIKit

private let albumArtSize:CGFloat = 100.0
private let bottomBorderHeight:CGFloat = 1.0

class KexpPlaylistCell: UITableViewCell {
    private var nowPlayingStackView: UIStackView = {
        let nowPlayingStackView = UIStackView()
        nowPlayingStackView.axis = .vertical
        nowPlayingStackView.distribution = .fillEqually
        nowPlayingStackView.translatesAutoresizingMaskIntoConstraints = false
        return nowPlayingStackView
    }()
    
    private var artistLabel: UILabel = {
        let artistLabel = UILabel()
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.font = UIFont.boldSystemFont(ofSize: FontSizes.xsmall)
        return artistLabel
    }()
    
    private var trackLabel: UILabel = {
        let trackLabel = UILabel()
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.font = UIFont.italicSystemFont(ofSize: FontSizes.xsmall)
        return trackLabel
    }()
    
    private var albumLabel: UILabel = {
        let albumLabel = UILabel()
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.font = UIFont.systemFont(ofSize: FontSizes.xsmall)
        albumLabel.textColor = UIColor.gray
        return albumLabel
    }()
    
    private var timePlayedLabel: UILabel = {
        let timePlayedLabel = UILabel()
        timePlayedLabel.translatesAutoresizingMaskIntoConstraints = false
        timePlayedLabel.font = UIFont.systemFont(ofSize: FontSizes.xxsmall)
        return timePlayedLabel
    }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma MM/dd/YYYY"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()

    private let albumArtImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    func configureNowPlayingCell(_ song: Play) {
        artistLabel.text = song.artist
        trackLabel.text = song.song
        albumLabel.text = song.album
        
        if let airdate = song.airdate {
            timePlayedLabel.text = dateFormatter.string(from: airdate)
        }
        
        albumArtImageView.fromURLSting(song.imageURI, placeHolder: UIImage(named: "vinylPlaceHolder"))
    }
}
