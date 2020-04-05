//
//  SettingsButton.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/2/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class SettingsButton: UIButton {
    let focusedScaleFactor : CGFloat = 1.2
    let focusedShadowRadius : CGFloat = 10
    let focusedShadowOpacity : Float = 0.25
    let shadowColor = UIColor.black.cgColor
    let shadowOffSetFocused = CGSize(width: 0, height: 0)
    let animationDuration = 0.2
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        coordinator.addCoordinatedAnimations({
            if self.isFocused{
                UIView.animate(withDuration: self.animationDuration, animations:{ [weak self] () -> Void in
                    guard let weakSelf = self else {return}
                    weakSelf.transform = CGAffineTransform(scaleX: weakSelf.focusedScaleFactor, y: weakSelf.focusedScaleFactor)
                            weakSelf.clipsToBounds = false
                            weakSelf.layer.shadowOpacity = weakSelf.focusedShadowOpacity
                            weakSelf.layer.shadowRadius = weakSelf.focusedShadowRadius
                            weakSelf.layer.shadowColor = weakSelf.shadowColor
                            weakSelf.layer.shadowOffset = weakSelf.shadowOffSetFocused

                        },completion:{ [weak self] finished in

                            guard let weakSelf = self else {return}
                            if !finished{
                                weakSelf.transform = CGAffineTransform(scaleX: weakSelf.focusedScaleFactor, y: weakSelf.focusedScaleFactor)
                                weakSelf.clipsToBounds = false
                                weakSelf.layer.shadowOpacity = weakSelf.focusedShadowOpacity
                                weakSelf.layer.shadowRadius = weakSelf.focusedShadowRadius
                                weakSelf.layer.shadowColor = weakSelf.shadowColor
                                weakSelf.layer.shadowOffset = weakSelf.shadowOffSetFocused
                            }

                        })
                } else {
                    UIView.animate(withDuration: self.animationDuration, animations:{  [weak self] () -> Void in
                        guard let weakSelf = self else {return}

                        weakSelf.clipsToBounds = true
                        weakSelf.transform = .identity

                        }, completion: {[weak self] finished in
                            guard let weakSelf = self else {return}
                            if !finished{
                                weakSelf.clipsToBounds = true
                                weakSelf.transform = .identity
                            }
                    })
                }
            }, completion: nil)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: animationDuration, animations: { [weak self] () -> Void in

            guard let weakSelf = self else {return}
            weakSelf.transform = .identity
            weakSelf.layer.shadowOffset = CGSize(width: 0, height: 10)

        })
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if isFocused{
            UIView.animate(withDuration: animationDuration, animations: { [weak self] () -> Void in
                guard let weakSelf = self else {return}
                weakSelf.transform = CGAffineTransform(scaleX: weakSelf.focusedScaleFactor, y: weakSelf.focusedScaleFactor)
                weakSelf.layer.shadowOffset = weakSelf.shadowOffSetFocused
            })
        }

    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        if isFocused{
            UIView.animate(withDuration: animationDuration, animations: {[weak self] () -> Void in
                guard let weakSelf = self else {return}
                weakSelf.transform = CGAffineTransform(scaleX: weakSelf.focusedScaleFactor, y: weakSelf.focusedScaleFactor)
                weakSelf.layer.shadowOffset = weakSelf.shadowOffSetFocused
            })
        }
    }
}
