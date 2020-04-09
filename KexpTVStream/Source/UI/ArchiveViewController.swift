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
    private let calendarCollectionView = CalendarCollectionView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.insertSegment(withTitle: "Date", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Host", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Show", at: 0, animated: true)
        segmentedControl.addTarget(self, action: #selector(handleUpdate(sender:)), for: .valueChanged)
        return segmentedControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        constructSubviews()
        constructConstraints()
        
        archiveManager.retrieveArchieveShows { [weak self] showsByDate, showsByShowName, showsByHostName, showsGenre in
   
            DispatchQueue.main.async {
                self?.calendarCollectionView.configureCalendar(with: showsByDate)
            }
        }
            
//            _ archiveShowsByDate: [[Date: [ArchiveShow]]],
//            _ archiveShowsByShowName: [[String: [ArchiveShow]]],
//            _ archiveShowsByHostName: [[String: [ArchiveShow]]],
//            _ archiveShowsGenre: [[String: [ArchiveShow]]]
        

    }
    
    func constructSubviews() {
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        containerView.addSubview(calendarCollectionView)
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
        
        NSLayoutConstraint.activate(
            [calendarCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
             calendarCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
             calendarCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
             calendarCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
    }
    
   @objc private func handleUpdate(sender: UISegmentedControl){
        let selectedIndex = sender.selectedSegmentIndex
    }
}
