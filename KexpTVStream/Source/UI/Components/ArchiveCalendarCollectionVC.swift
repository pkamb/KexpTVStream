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
    func didSectionArchieveDate(archiveShows: [ArchiveShow])
}

class ArchiveCalendarCollectionVC: UICollectionViewController {
    enum DisplayType {
        case full
        case detail
    }
    
    private let layout = UICollectionViewFlowLayout()
    private var showsByDate: [[Date: [ArchiveShow]]]?
    private let displayType: DisplayType
    
    weak var archiveCalendarDelegate: ArchiveCalendarDelegate?

    init(displayType: DisplayType) {
        self.displayType = displayType
        
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(collectionViewLayout: layout)

        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DayCollectionCell.self, forCellWithReuseIdentifier: DayCollectionCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white
        
        if displayType == .detail {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
        }
    }
    
    func configure(with showsByDate: [[Date: [ArchiveShow]]]) {
        self.showsByDate = showsByDate
        collectionView.reloadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ArchiveCalendarCollectionVC: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if displayType == .detail {
            return showsByDate?.first?.first?.value.count ?? 0
        }
        
        return showsByDate?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCollectionCell.reuseIdentifier, for: indexPath as IndexPath) as! DayCollectionCell
        
        if displayType == .full {
            let showByDate = showsByDate?[indexPath.row]
            cell.configure(with: showByDate?.keys.first ?? Date())
        } else {
            let showByDate = showsByDate?.first?.first?.value[indexPath.row]
            cell.configure(with: showByDate?.show.startTime ?? Date())
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let showByDate = showsByDate?[indexPath.row]

        if let archiveShow = showByDate?.values.first {
             archiveCalendarDelegate?.didSectionArchieveDate(archiveShows: archiveShow)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard var containerWidth = view.superview?.frame.width else { return CGSize.zero }
        
        containerWidth = containerWidth - collectionView.contentInset.left - collectionView.contentInset.right

        let cellWidth = containerWidth/7.0
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = collectionView.cellForItem(at: previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = .gray
        }

        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = collectionView.cellForItem(at: nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = .white
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
        return label
    }()
    
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let dayOfWeekLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
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
        contentView.layer.borderWidth = 1.0
        contentView.backgroundColor = .gray
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
            [stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
             stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
             stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
