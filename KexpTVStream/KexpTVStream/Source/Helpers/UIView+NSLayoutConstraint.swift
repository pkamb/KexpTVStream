//
//  NSLayoutConstraintExtensions.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/15/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

extension UIView {
    func activateConstraints(_ constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
    
    func constrain(within view: UIView, insets: UIEdgeInsets = .zero) {
        let constraints: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right)
        ]

        activateConstraints(constraints)
    }

    func addSubview(_ view: UIView, constraints: [NSLayoutConstraint]) {
        addSubview(view)
        view.activateConstraints(constraints)
    }

    func addPinnedSubview(_ view: UIView, insets: UIEdgeInsets = .zero) {
        addSubview(view)
        view.constrain(within: view.superview ?? self, insets: insets)
    }
}
