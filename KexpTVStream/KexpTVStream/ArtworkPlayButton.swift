//
//  ArtworkPlayButton.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 9/23/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import UIKit

class ArtworkPlayButton: UIButton {
    // MARK: - Properties
    
    private lazy var pauseImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "pauseButton")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = .white
        imageView.alpha = 0.0
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    } ()
    
    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayView.alpha = 0.0
        overlayView.frame = self.bounds
        
        return overlayView
    } ()
    
    // MARK: - Init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubviews()
        addConstraints()
    }
    
    private func addSubviews() {
        addSubview(overlayView)
        addSubview(pauseImageView)
    }
    
    private func addConstraints() {
        pauseImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        pauseImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    // MARK: - Public
    
    func updateState(pause: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
            self.overlayView.alpha = pause ? 1.0 : 0.0
            self.pauseImageView.alpha = pause ? 1.0 : 0.0

        }, completion: nil)
    }
}
