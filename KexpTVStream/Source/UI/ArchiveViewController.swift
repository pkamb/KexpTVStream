//
//  ArchiveViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/8/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower
import UIKit

class ArchiveViewController: UIViewController {
    private let archiveManager = ArchiveManager()
    private let calendarCollectionView = ArchiveCalendarCollectionView()
    private let hostArchieveCollectionView = ArchiveDetailCollectionView(with: .host)
    private let showArchieveCollectionView = ArchiveDetailCollectionView(with: .show)
    private let genreArchieveCollectionView = ArchiveDetailCollectionView(with: .genre)
    
    private lazy var archieveCollectionViews: [UICollectionView] = {
        return [calendarCollectionView,
                hostArchieveCollectionView,
                showArchieveCollectionView,
                genreArchieveCollectionView]
    } ()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Date", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Host", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "Show", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "Genre", at: 3, animated: true)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(handleUpdate(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constructSubviews()
        constructConstraints()
        _ = archieveCollectionViews.map { $0.isHidden = true }
    
        calendarCollectionView.archiveCalendarDelegate = self
        
        view.backgroundColor = .white
        
        archiveManager.retrieveArchieveShows { [weak self] showsByDate, showsByShowName, showsByHostName, showsGenre in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.hostArchieveCollectionView.isHidden = false
                
                strongSelf.calendarCollectionView.configure(with: showsByDate)
                strongSelf.hostArchieveCollectionView.configure(with: showsByHostName)
                strongSelf.showArchieveCollectionView.configure(with: showsByShowName)
                strongSelf.genreArchieveCollectionView.configure(with: showsGenre)
            }
        }
    }
    
    func constructSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        containerView.addSubview(calendarCollectionView)
        containerView.addSubview(hostArchieveCollectionView)
        containerView.addSubview(showArchieveCollectionView)
        containerView.addSubview(genreArchieveCollectionView)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate(
            [containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 100),
             containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
             containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
             containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        archieveCollectionViews.forEach { cv in
            NSLayoutConstraint.activate(
                [cv.topAnchor.constraint(equalTo: self.containerView.topAnchor),
                 cv.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
                 cv.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
                 cv.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
                ])
        }
    }
    
   @objc private func handleUpdate(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
    
        _ = archieveCollectionViews.map { $0.isHidden = true }
    
        if selectedIndex == 0  {
            calendarCollectionView.isHidden = false
        } else if selectedIndex == 1 {
            hostArchieveCollectionView.isHidden = false
        } else if selectedIndex == 2 {
            showArchieveCollectionView.isHidden = false
        } else if selectedIndex == 3 {
            genreArchieveCollectionView.isHidden = false
        }
    }
}

extension ArchiveViewController: ArchiveCalendarDelegate {
    func didSectionArchieveDate(archiveShow: [ArchiveShow]) {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        
    }
}
