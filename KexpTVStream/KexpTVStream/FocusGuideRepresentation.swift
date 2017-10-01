//
//  FocusGuideRepresentation.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 9/23/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import UIKit

class FocusGuideRepresentation: UIView {
    init(frameSize: CGRect, label: String) {
        super.init(frame: frameSize)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        let myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        myLabel.font = UIFont.systemFont(ofSize: 20)
        myLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        myLabel.textAlignment = .center
        myLabel.text = label.uppercased()
        self.addSubview(myLabel)
        
        // Add a dashed rule around myself.
        let border = CAShapeLayer()
        border.strokeColor = UIColor.white.withAlphaComponent(0.4).cgColor
        border.fillColor = nil
        border.lineWidth = 1
        border.lineDashPattern = [4, 4]
        border.path = UIBezierPath(rect: bounds).cgPath
        border.frame = bounds
        self.layer.addSublayer(border)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
