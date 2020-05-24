//
//  ArchiveCalendarCollectionVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/8/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit
import KEXPPower

protocol ArchiveCalendarDelegate: class {
    func didSelectArchieveDate(archiveShows: [ArchiveShow])
    func didSelectArchieveShow(archiveShow: ArchiveShow)
}

class ArchiveCalendarCollectionVC: BaseViewController, UICollectionViewDataSource {
    enum DisplayType {
        case full
        case detail
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DayCollectionCell.self, forCellWithReuseIdentifier: DayCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    } ()

    private var showsByDate: [DateShows]?
    private let displayType: DisplayType
    
    weak var archiveCalendarDelegate: ArchiveCalendarDelegate?

    init(displayType: DisplayType) {
        self.displayType = displayType
        super.init(nibName: nil, bundle: nil)
    }
    
    override func setupViews() {
        collectionView.backgroundColor = .clear
        
        if displayType == .detail {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
        } else {
            removeBackgroundGradient()
        }
    }
    
    override func constructSubviews() {
        view.addPinnedSubview(collectionView)
    }

    func configure(with showsByDate: [DateShows]) {
        self.showsByDate = showsByDate
        collectionView.reloadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ArchiveCalendarCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayType == .detail {
            return showsByDate?.count ?? 0
        }
        
        return showsByDate?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCollectionCell.reuseIdentifier, for: indexPath as IndexPath) as! DayCollectionCell
        
        if
            displayType == .full,
            let showByDate = showsByDate?[indexPath.row]
        {
            cell.configure(with: showByDate.date)
        } else if let showByDate = showsByDate?[indexPath.row] {
            cell.configure(with: showByDate.date)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if
            displayType == .detail,
            showsByDate?[indexPath.row].shows.count == 1,
            let archiveShow = showsByDate?[indexPath.row].shows.first,
            let tabBarController = self.presentingViewController as? UITabBarController
        {
            archiveCalendarDelegate?.didSelectArchieveShow(archiveShow: archiveShow)
            tabBarController.selectedIndex = 0
            dismiss(animated: true, completion: nil)
        } else if let showByDate = showsByDate?[indexPath.row] {
            archiveCalendarDelegate?.didSelectArchieveDate(archiveShows: showByDate.shows)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard var containerWidth = view.superview?.frame.width else { return CGSize.zero }
        
        containerWidth = containerWidth - collectionView.contentInset.left - collectionView.contentInset.right

        let cellWidth = containerWidth/7.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = collectionView.cellForItem(at: previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = .white
        }

        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = collectionView.cellForItem(at: nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = UIColor.kexpOrange().withAlphaComponent(0.8)
        }
    }
}

private class DayCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "DayCell"
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Calander.Month.font
        label.textColor = ThemeManager.Archive.Calander.Month.textColor
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Calander.Day.font
        label.textColor = ThemeManager.Archive.Calander.Day.textColor
        return label
    }()
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Calander.DayOfWeek.font
        label.textColor = ThemeManager.Archive.Calander.DayOfWeek.textColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)

        setupSubviews()
        constructSubviews()
        constructConstraints()
    }
    
    func setupSubviews() {
        contentView.layer.borderColor = UIColor.black.cgColor
        contentView.layer.borderWidth = 0.5
        contentView.backgroundColor = .white
    }
    
    func configure(with date: Date) {
        monthLabel.text = DateFormatter.monthFormatter.string(from: date)
        dayLabel.text = DateFormatter.dayFormatter.string(from: date)
        dayOfWeekLabel.text = DateFormatter.dayOfWeekFormatter.string(from: date)
    }
    
    private func constructSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(monthLabel)
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(dayOfWeekLabel)
    }
    
    private func constructConstraints() {
        NSLayoutConstraint.activate(
            [stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
            ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
