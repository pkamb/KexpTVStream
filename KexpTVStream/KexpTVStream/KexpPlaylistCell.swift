//
//  KexpPlaylistCell.swift
//  KexpTVStream
//
//  Created by Ryan Garchinsky on 1/12/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import Foundation
import UIKit

class KexpPlaylistCell: UITableViewCell {
    
    let artistLabel = UILabel()
    let trackLabel = UILabel()
    let albumLabel = UILabel()
    let albumArtImageView = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .None
        
        
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(artistLabel)
        
        let views = ["settingsLabel": artistLabel]
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[settingsLabel]-|",
                options: .AlignAllCenterY,
                metrics:nil,
                views: views
            )
        )
        
        NSLayoutConstraint.activateConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-mMargin-[settingsLabel]-mMargin-|",
                options: [],
                metrics:nil,
                views: views
            )
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}