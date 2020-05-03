//
//  CustomActivityIndicator.swift
//  KEXP Radio
//
//  Created by Dustin Bergman on 12/27/17.
//  Copyright © 2017 KEXP. All rights reserved.
//

import UIKit

private let activityIndicatorTransformRotationKey = "transform.rotation"

public class CustomActivityIndicator: UIImageView {
    public init() {
        super.init(image: UIImage(named: "activityIndicator"))
        tintColor = .white
        alpha = 0.0
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        alpha = 0.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    func showActivityLoading() {
        DispatchQueue.main.async {
            self.alpha = 1.0
            let rotationAnimation = CABasicAnimation(keyPath: activityIndicatorTransformRotationKey)
            rotationAnimation.isRemovedOnCompletion = false
            rotationAnimation.fromValue = 0.0;
            rotationAnimation.toValue = Float(Float.pi * 2.0)
            rotationAnimation.duration = 0.8
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = Float.infinity
            self.layer.add(rotationAnimation, forKey: activityIndicatorTransformRotationKey)
        }
    }
    
    func hideActivityLoading() {
        alpha = 0.0
        layer.removeAllAnimations()
    }
}
