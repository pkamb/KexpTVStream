//
//  StartTimesCollectionViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/5/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

protocol StartTimesDelegate: class {
    func playShow(archiveShow: ArchiveShow, archiveShowStart: ArchiveShowStart)
}

class StartTimesCollectionViewController: BaseViewController {
    private let archiveManager = ArchiveManager()
    private let archiveShow: ArchiveShow
    private var archiveShowStartTimes: [ArchiveShowStart]?
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 200, height: 50)
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(StartTimeCell.self, forCellWithReuseIdentifier: StartTimeCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    weak var startTimesDelegate: StartTimesDelegate?
    
    init(archiveShow: ArchiveShow) {
        self.archiveShow = archiveShow
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        archiveManager.archiveStreamStartTimes(with: archiveShow) { [weak self] archiveStartDetails -> (Void) in
            self?.archiveShowStartTimes = archiveStartDetails
        }
    }
    
    override func constructSubviews() {
        view.addSubview(collectionView)
    }
    
    override func constructConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -200),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 200)
        ])
    }
}

extension StartTimesCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archiveShowStartTimes?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StartTimeCell.reuseIdentifier, for: indexPath) as! StartTimeCell
        let archiveShowStartTime = archiveShowStartTimes?[indexPath.row]
    
        cell.configure(with: archiveShowStartTime)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedStartTime = archiveShowStartTimes?[indexPath.row] else { return }
        
        startTimesDelegate?.playShow(archiveShow: archiveShow, archiveShowStart: selectedStartTime)
        dismiss(animated: true, completion: nil)
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

class StartTimeCell: UICollectionViewCell {
    static let reuseIdentifier = "StartTimeCell"
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = ThemeManager.Archive.StartShow.font
        label.textColor = ThemeManager.Archive.StartShow.textColor
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupSubviews()
        constructSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        timeLabel.text = nil
    }
    
    func setupSubviews() {
        contentView.backgroundColor = .white
    }
    
    func constructSubviews() {
        contentView.addPinnedSubview(timeLabel)
    }

    func configure(with startTime: ArchiveShowStart?) {
        timeLabel.text = startTime?.startTimeDisplay
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
