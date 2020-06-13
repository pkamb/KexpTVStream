//
//  PlayingIndicator.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/28/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

class PlayingIndicatorView: UIView {
    struct BarHeights {
        static let firstBar = CGFloat(17.0)
        static let secondBar = CGFloat(13.0)
        static let thirdBar = CGFloat(19.0)
        static let fourthBar = CGFloat(15.0)
    }

    private let barContainer: UIView = {
        let view = UIView()
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

        
    func setupViews() {
        backgroundColor = .white
    }
    
    func constructSubviews() {
        addPinnedSubview(barContainer)

        barContainer.addSubview(firstView)
        barContainer.addSubview(secondView)
        barContainer.addSubview(thirdView)
        barContainer.addSubview(fourthView)
    }
    
    func constructConstraints() {
        barContainer.heightAnchor.constraint(equalToConstant: 20).isActive = true
       // barContainer.widthAnchor.constraint(equalToConstant: 20).isActive = true

        firstHeightConstraint = firstView.heightAnchor.constraint(equalToConstant: BarHeights.firstBar)
        firstHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            firstView.widthAnchor.constraint(equalToConstant: 5),
            firstView.leadingAnchor.constraint(equalTo: barContainer.leadingAnchor),
            firstView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        secondHeightConstraint = secondView.heightAnchor.constraint(equalToConstant: BarHeights.secondBar)
        secondHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            secondView.widthAnchor.constraint(equalToConstant: 5),
            secondView.leadingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: 5),
            secondView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        thirdHeightConstraint = thirdView.heightAnchor.constraint(equalToConstant: BarHeights.thirdBar)
        thirdHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            thirdView.widthAnchor.constraint(equalToConstant: 5),
            thirdView.leadingAnchor.constraint(equalTo: secondView.trailingAnchor, constant: 5),
            thirdView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])

        fourthtHeightConstraint = fourthView.heightAnchor.constraint(equalToConstant: BarHeights.fourthBar)
        fourthtHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            fourthView.widthAnchor.constraint(equalToConstant: 5),
            fourthView.leadingAnchor.constraint(equalTo: thirdView.trailingAnchor, constant: 5),
            fourthView.trailingAnchor.constraint(equalTo: trailingAnchor),
            fourthView.bottomAnchor.constraint(equalTo: barContainer.bottomAnchor)
        ])
    }
    
    func startAnimating() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.firstHeightConstraint?.isActive = false
            self.secondHeightConstraint?.isActive = false
            self.thirdHeightConstraint?.isActive = false
            self.fourthtHeightConstraint?.isActive = false

            self.firstHeightConstraint?.constant = CGFloat.random(in: 0..<94)
            self.secondHeightConstraint?.constant = CGFloat.random(in: 0..<94)
            self.thirdHeightConstraint?.constant = CGFloat.random(in: 0..<94)
            self.fourthtHeightConstraint?.constant = CGFloat.random(in: 0..<94)

            self.firstHeightConstraint?.isActive = true
            self.secondHeightConstraint?.isActive = true
            self.thirdHeightConstraint?.isActive = true
            self.fourthtHeightConstraint?.isActive = true

            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    

//        override func viewDidAppear(_ animated: Bool) {
//            super.viewDidAppear(animated)
//
//            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
//                self.firstHeightConstraint?.isActive = false
//                self.secondHeightConstraint?.isActive = false
//                self.thirdHeightConstraint?.isActive = false
//                self.fourthtHeightConstraint?.isActive = false
//
//                self.firstHeightConstraint?.constant = CGFloat.random(in: 0..<94)
//                self.secondHeightConstraint?.constant = CGFloat.random(in: 0..<94)
//                self.thirdHeightConstraint?.constant = CGFloat.random(in: 0..<94)
//                self.fourthtHeightConstraint?.constant = CGFloat.random(in: 0..<94)
//
//                self.firstHeightConstraint?.isActive = true
//                self.secondHeightConstraint?.isActive = true
//                self.thirdHeightConstraint?.isActive = true
//                self.fourthtHeightConstraint?.isActive = true
//
//                UIView.animate(withDuration: 0.3) {
//                    self.view.layoutIfNeeded()
//                }
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.firstHeightConstraint?.isActive = false
//                self.secondHeightConstraint?.isActive = false
//                self.thirdHeightConstraint?.isActive = false
//                self.fourthtHeightConstraint?.isActive = false
//
//                self.firstHeightConstraint?.constant = BarHeights.firstBar
//                self.secondHeightConstraint?.constant = BarHeights.secondBar
//                self.thirdHeightConstraint?.constant = BarHeights.thirdBar
//                self.fourthtHeightConstraint?.constant = BarHeights.fourthBar
//
//                self.firstHeightConstraint?.isActive = true
//                self.secondHeightConstraint?.isActive = true
//                self.thirdHeightConstraint?.isActive = true
//                self.fourthtHeightConstraint?.isActive = true
//
//                self.timer.invalidate()
//
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.view.layoutIfNeeded()
//                }) { _ in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                        self.performSegue(withIdentifier: "mainSegue", sender: self)
//                    }
//                }
//            }
//        }
//    }

}
