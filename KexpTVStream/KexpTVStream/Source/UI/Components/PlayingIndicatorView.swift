//
//  PlayingIndicatorView.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/28/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class PlayingIndicatorView: UIView {
    struct BarStyle {
        static let height = CGFloat(20.0)
        static let barWidth = CGFloat(5.0)
        static let barSpace = CGFloat(3.0)
        static let firstBar = CGFloat(17.0)
        static let secondBar = CGFloat(13.0)
        static let thirdBar = CGFloat(19.0)
        static let fourthBar = CGFloat(15.0)
    }

    private let barContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let firstView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let secondView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let thirdView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private let fourthView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()

    private var firstHeightConstraint: NSLayoutConstraint?
    private var secondHeightConstraint: NSLayoutConstraint?
    private var thirdHeightConstraint: NSLayoutConstraint?
    private var fourthtHeightConstraint: NSLayoutConstraint?

    private var timer = Timer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        constructSubviews()
        constructConstraints()
    }

    private func setupViews() {
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
    
    private func constructSubviews() {
        addPinnedSubview(barContainer)

        barContainer.addSubview(firstView)
        barContainer.addSubview(secondView)
        barContainer.addSubview(thirdView)
        barContainer.addSubview(fourthView)
    }
    
    private func constructConstraints() {
        barContainer.heightAnchor.constraint(equalToConstant: BarStyle.height).isActive = true

        firstHeightConstraint = firstView.heightAnchor.constraint(equalToConstant: BarStyle.firstBar)
        firstHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            firstView.widthAnchor.constraint(equalToConstant: BarStyle.barWidth),
            firstView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor, constant: BarStyle.barSpace),
            firstView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        secondHeightConstraint = secondView.heightAnchor.constraint(equalToConstant: BarStyle.secondBar)
        secondHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            secondView.widthAnchor.constraint(equalToConstant: BarStyle.barWidth),
            secondView.leadingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: BarStyle.barSpace),
            secondView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        thirdHeightConstraint = thirdView.heightAnchor.constraint(equalToConstant: BarStyle.thirdBar)
        thirdHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            thirdView.widthAnchor.constraint(equalToConstant: BarStyle.barWidth),
            thirdView.leadingAnchor.constraint(equalTo: secondView.trailingAnchor, constant: BarStyle.barSpace),
            thirdView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        fourthtHeightConstraint = fourthView.heightAnchor.constraint(equalToConstant: BarStyle.fourthBar)
        fourthtHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            fourthView.widthAnchor.constraint(equalToConstant: BarStyle.barWidth),
            fourthView.leadingAnchor.constraint(equalTo: thirdView.trailingAnchor, constant: BarStyle.barSpace),
            fourthView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -BarStyle.barSpace),
            fourthView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])
    }
    
    func startAnimating() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.firstHeightConstraint?.isActive = false
            self.secondHeightConstraint?.isActive = false
            self.thirdHeightConstraint?.isActive = false
            self.fourthtHeightConstraint?.isActive = false

            self.firstHeightConstraint?.constant = CGFloat.random(in: 0..<BarStyle.height)
            self.secondHeightConstraint?.constant = CGFloat.random(in: 0..<BarStyle.height)
            self.thirdHeightConstraint?.constant = CGFloat.random(in: 0..<BarStyle.height)
            self.fourthtHeightConstraint?.constant = CGFloat.random(in: 0..<BarStyle.height)

            self.firstHeightConstraint?.isActive = true
            self.secondHeightConstraint?.isActive = true
            self.thirdHeightConstraint?.isActive = true
            self.fourthtHeightConstraint?.isActive = true

            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    func stopAnimating() {
        self.firstHeightConstraint?.isActive = false
        self.secondHeightConstraint?.isActive = false
        self.thirdHeightConstraint?.isActive = false
        self.fourthtHeightConstraint?.isActive = false

        self.firstHeightConstraint?.constant = BarStyle.firstBar
        self.secondHeightConstraint?.constant = BarStyle.secondBar
        self.thirdHeightConstraint?.constant = BarStyle.thirdBar
        self.fourthtHeightConstraint?.constant = BarStyle.fourthBar

        self.firstHeightConstraint?.isActive = true
        self.secondHeightConstraint?.isActive = true
        self.thirdHeightConstraint?.isActive = true
        self.fourthtHeightConstraint?.isActive = true

        self.timer.invalidate()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
        })
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
