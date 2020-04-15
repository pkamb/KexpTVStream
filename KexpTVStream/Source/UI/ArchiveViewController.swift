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
    private let calendarCollectionVC = ArchiveCalendarCollectionVC(displayType: .full)
    private let hostArchieveCollectionVC = ArchiveDetailCollectionVC(with: .host)
    private let showArchieveCollectionVC = ArchiveDetailCollectionVC(with: .show)
    private let genreArchieveCollectionVC = ArchiveDetailCollectionVC(with: .genre)
    
    private lazy var archieveCollectionViews: [UIViewController] = {
        return [calendarCollectionVC,
                hostArchieveCollectionVC,
                showArchieveCollectionVC,
                genreArchieveCollectionVC]
    } ()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let archiveSelectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
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
    
        calendarCollectionVC.archiveCalendarDelegate = self
        hostArchieveCollectionVC.archiveDetailDelegate = self
        showArchieveCollectionVC.archiveDetailDelegate = self
        genreArchieveCollectionVC.archiveDetailDelegate = self
        
        view.backgroundColor = .white
        
        archiveManager.retrieveArchieveShows { [weak self] showsByDate, showsByShowName, showsByHostName, showsGenre in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.calendarCollectionVC.view.isHidden = false
                strongSelf.archiveSelectionLabel.text = "Select a Date"
                
                strongSelf.calendarCollectionVC.configure(with: showsByDate)
                strongSelf.showArchieveCollectionVC.configure(with: showsByShowName)
                strongSelf.hostArchieveCollectionVC.configure(with: showsByHostName)
                strongSelf.genreArchieveCollectionVC.configure(with: showsGenre)
            }
        }
    }
    
    func constructSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(archiveSelectionLabel)
        view.addSubview(containerView)
        
        archieveCollectionViews.forEach { cv in
            cv.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(cv.view)
            addChild(cv)
            cv.didMove(toParent: self)
            cv.view.isHidden = true
        }
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
             segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        
        NSLayoutConstraint.activate(
            [archiveSelectionLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -30),
             archiveSelectionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
            ])
        
        NSLayoutConstraint.activate(
            [containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 100),
             containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
             containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
             containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        
        archieveCollectionViews.forEach { cv in
            NSLayoutConstraint.activate(
                [cv.view.topAnchor.constraint(equalTo: self.containerView.topAnchor),
                 cv.view.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
                 cv.view.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
                 cv.view.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
                ])
        }

    }
    
   @objc private func handleUpdate(sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
    
        _ = archieveCollectionViews.map { $0.view.isHidden = true }
    
        if selectedIndex == 0  {
            calendarCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Date"
        } else if selectedIndex == 1 {
            hostArchieveCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Host"
        } else if selectedIndex == 2 {
            showArchieveCollectionVC.view.isHidden = false
            archiveSelectionLabel.text = "Select a Show"
        } else if selectedIndex == 3 {
            archiveSelectionLabel.text = "Select a Genre"
            genreArchieveCollectionVC.view.isHidden = false
        }
    }
}

extension ArchiveViewController: ArchiveCalendarDelegate {
    func didSectionArchieveDate(archiveShows: [ArchiveShow]) {
        let showsVC = ArchiveDetailCollectionVC(with: .day)
        showsVC.configure(with: [["" : archiveShows]])
        let navigationController = UINavigationController(rootViewController: showsVC)
        showsVC.title = "Select a Show"
        
        show(navigationController, sender: self)
    }
}

extension ArchiveViewController: ArchiveDetailDelegate {
    func didSectionArchieve(archiveShows: [ArchiveShow], type: ArchiveDetailCollectionVC.ArchiveType) {
        
        let archiveCalendarVC = ArchiveCalendarCollectionVC(displayType: .detail)
        archiveCalendarVC.configure(with: [[Date(): archiveShows]])
        let navigationController = UINavigationController(rootViewController: archiveCalendarVC)
        
        let vcTitle: String
        
        switch type {
        case .show: vcTitle = "\(archiveShows.first?.show.programName ?? "")"
        case .host: vcTitle = "\(archiveShows.first?.show.hostNames?.first ?? "")"
        case .genre: vcTitle = "\(archiveShows.first?.show.programTags ?? "")"
        default: vcTitle = ""
        }
        
        archiveCalendarVC.title = vcTitle
        show(navigationController, sender: self)
    }
}
