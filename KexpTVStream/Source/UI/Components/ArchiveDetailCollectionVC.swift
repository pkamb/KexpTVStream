//
//  ArchiveDetailCollectionVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/12/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

protocol ArchiveDetailDelegate: class {
    func didSelectArchive(archiveShows: [ArchiveShow], type: ArchiveDetailCollectionVC.ArchiveType)
}

class ArchiveDetailCollectionVC: BaseViewController {
    struct ArchiveContent {
        let contentName: String
        let shows: [ArchiveShow]
    }
    
    fileprivate enum Layout {
        static let hostCellHeight: CGFloat = 200
        static let showCellHeight: CGFloat = 200
        static let dayCellHeight: CGFloat = 200
        static let genreCellHeight: CGFloat = 100
        static let imageSize: CGFloat = 150
    }
    
    enum ArchiveType {
        case day
        case host
        case show
        case genre
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ArchiveDetailCollectionCell.self, forCellWithReuseIdentifier: ArchiveDetailCollectionCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    private var archiveType: ArchiveType
    private var archieveShows: [ArchiveContent]?
    
    weak var archiveDetailDelegate: ArchiveDetailDelegate?

    init(with archiveType: ArchiveType) {
        self.archiveType = archiveType
        super.init(nibName: nil, bundle: nil)
    }
    
    override func setupViews() {
        collectionView.backgroundColor = .clear
        
        if archiveType == .day {
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 100, bottom: 0, right: 100)
        }
    }
    
    override func constructSubviews() {
        view.addPinnedSubview(collectionView)
    }
    
    func configure(with archieveShows: [ArchiveContent]) {
        self.archieveShows = archieveShows
        collectionView.reloadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ArchiveDetailCollectionVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if case .day = archiveType {
            return archieveShows?.count ?? 0
        }
        
        return archieveShows?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveDetailCollectionCell.reuseIdentifier, for: indexPath as IndexPath) as! ArchiveDetailCollectionCell
        
        if archiveType == .day {
            let archieveShow = archieveShows?[indexPath.row]
            cell.configureForDay(with : archieveShow?.shows.first)
        } else {
            let archieveShow = archieveShows?[indexPath.row]
            cell.configure(type: archiveType, archiveShows: archieveShow?.shows)
            removeBackgroundGradient()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let archieveShows = archieveShows?[indexPath.row] else { return }

        archiveDetailDelegate?.didSelectArchive(archiveShows: archieveShows.shows, type: archiveType)

        if
            archiveType == .day,
            let tabBarController = self.presentingViewController as? UITabBarController
        {
            tabBarController.selectedIndex = 0
            dismiss(animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard var containerWidth = view?.frame.width else { return CGSize.zero }

        containerWidth = containerWidth - collectionView.contentInset.left - collectionView.contentInset.right
        let cellWidth = containerWidth / 2.0
    
        return CGSize(width: cellWidth, height: getCellHeight())
    }
    
    private func getCellHeight() -> CGFloat {
        switch archiveType {
        case .genre: return Layout.genreCellHeight
        case .host: return Layout.hostCellHeight
        case .show: return Layout.showCellHeight
        case .day: return Layout.dayCellHeight
        }
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

private class ArchiveDetailCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "DetailCell"
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let topLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Details.TopRow.font
        label.textColor = ThemeManager.Archive.Details.TopRow.textColor
        return label
    }()

    private let middleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Details.MiddleRow.font
        label.textColor = ThemeManager.Archive.Details.MiddleRow.textColor
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.Details.BottomRow.font
        label.textColor = ThemeManager.Archive.Details.BottomRow.textColor
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = ThemeManager.Archive.Details.Info.font
        label.textColor = ThemeManager.Archive.Details.Info.textColor
        return label
    }()
    
    private let archiveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = ArchiveDetailCollectionVC.Layout.imageSize / 2
        imageView.clipsToBounds = true
        return imageView
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
        contentView.backgroundColor = .white
    }
    
    private func constructSubviews() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(archiveImageView)
        contentStackView.addArrangedSubview(labelStackView)
        contentStackView.addArrangedSubview(infoLabel)
        
        labelStackView.addArrangedSubview(topLabel)
        labelStackView.addArrangedSubview(middleLabel)
        labelStackView.addArrangedSubview(bottomLabel)
    }
    
    private func constructConstraints() {
        NSLayoutConstraint.activate(
            [contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
             contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20.0),
             contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
             contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
        NSLayoutConstraint.activate([
            archiveImageView.heightAnchor.constraint(equalToConstant: ArchiveDetailCollectionVC.Layout.imageSize),
            archiveImageView.widthAnchor.constraint(equalToConstant: ArchiveDetailCollectionVC.Layout.imageSize)
        ])
    }
    
    func configureForDay(with archiveShow: ArchiveShow?) {
        archiveImageView.fromURLSting(archiveShow?.show.imageURI)
        topLabel.text = archiveShow?.show.programName
        middleLabel.text = archiveShow?.show.hostNames?.first?.uppercased()
        bottomLabel.text = archiveShow?.show.programTags
        
        if let startTime = archiveShow?.show.startTime {
            infoLabel.text = DateFormatter.displayFormatter.string(from: startTime)
        }
    }
    
    func configure(type: ArchiveDetailCollectionVC.ArchiveType, archiveShows: [ArchiveShow]?) {
        let archiveShow = archiveShows?.first?.show
        let showCount = archiveShows?.count
        
        let infoText: String
        
        if showCount == 1 {
            infoText = "1 SHOW"
        } else if let showCount = showCount {
            infoText = "\(showCount) SHOWS"
        } else {
            infoText = ""
        }
        
        switch type {
        case .host:
            archiveImageView.fromURLSting(archiveShow?.imageURI)
            topLabel.text = archiveShow?.hostNames?.first
            middleLabel.text = archiveShow?.programName?.uppercased()
            bottomLabel.text = archiveShow?.programTags
            infoLabel.text = infoText
            
        case .show, .day:
            archiveImageView.fromURLSting(archiveShow?.imageURI)
            topLabel.text = archiveShow?.programName
            middleLabel.text = archiveShow?.hostNames?.joined(separator: ", ").uppercased()
            bottomLabel.text = archiveShow?.programTags
            infoLabel.text = infoText
            
        case .genre:
            topLabel.text = archiveShow?.programTags
            infoLabel.text = infoText
            archiveImageView.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ArchiveDetailCollectionVC.ArchiveContent {
    init(_ showName: ShowNameShows) {
        contentName = showName.showName
        shows = showName.shows
    }
    
    init(_ hostName: HostNameShows) {
        contentName = hostName.hostName
        shows = hostName.shows
    }
    
    init(_ genre: GenreShows) {
        contentName = genre.genre
        shows = genre.shows
    }
    
    init?(_ type: ArchiveDetailCollectionVC.ArchiveType, archiveShow: ArchiveShow) {
        switch type {
        case .day:
            contentName = archiveShow.show.programName ?? ""
            shows = [archiveShow]

        default:
            return nil
        }
    }
}
