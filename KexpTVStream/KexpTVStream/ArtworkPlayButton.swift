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
    
    private lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        overlayView.alpha = 0.0
        overlayView.frame = self.bounds
        
        return overlayView
    } ()
    
    var actionButtonIsDisplaying = false
    var showingDefaultImage = true
    
    override var isSelected: Bool {
        didSet {
            setImage(isSelected ? UIImage(named: "pauseButton") : UIImage(named: "playButton"), for: UIControl.State())
            overlayView.alpha = showingDefaultImage ? 0.0 : 1.0
            
            DispatchQueue.main.async { self.hidePlayButtonActionImage() }
        }
    }
    
    // MARK: - Init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(overlayView)

        imageView?.alpha = 0.0
        tintColor = .white
        setImage(UIImage(named: "playButton"), for: .normal)
        
        if let imageView = imageView {
            bringSubviewToFront(imageView)
        }
    }

    // MARK: - Public
    
    func showPlayButtonActionImage() {
        guard !actionButtonIsDisplaying else { return }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .layoutSubviews, animations: {
            self.overlayView.alpha = self.showingDefaultImage ? 0.0 : 1.0
            self.imageView?.alpha = 1.0
            self.actionButtonIsDisplaying = true
        }, completion: { done in
            self.hidePlayButtonActionImage()
        })
    }

    private func hidePlayButtonActionImage() {
        UIView.animate(withDuration: 0.3, delay: 2.0, options: .layoutSubviews, animations: {
            self.overlayView.alpha = 0.0
            self.imageView?.alpha = 0.0
            self.actionButtonIsDisplaying = false
        })
    }
    
    // MARK: - UIFocusEnvironment
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({ [weak self] in
            guard let strongSelf = self, strongSelf.isFocused else { DispatchQueue.main.async { self?.hidePlayButtonActionImage() }; return }
            
            strongSelf.imageView?.alpha = 0.0
            strongSelf.actionButtonIsDisplaying = false
            
            UIView.animate(withDuration: 0.2, animations: {
                strongSelf.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { done in
                UIView.animate(withDuration: 0.2, animations: {
                    strongSelf.transform = CGAffineTransform.identity
                    strongSelf.overlayView.alpha = strongSelf.showingDefaultImage ? 0.0 : 1.0
                    strongSelf.imageView?.alpha = 1.0
                    strongSelf.actionButtonIsDisplaying = true
                }, completion: { _ in
                    strongSelf.hidePlayButtonActionImage()
                })
            })
        })
    }
}
