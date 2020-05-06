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

class StartTimesCollectionViewController: UICollectionViewController {
    private let archiveManager = ArchiveManager()
    private let archiveShow: ArchiveShow
    private var archiveShowStartTimes: [ArchiveShowStart]?
    
    weak var startTimesDelegate: StartTimesDelegate?
    
    init(archiveShow: ArchiveShow) {
        self.archiveShow = archiveShow
        
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        archiveManager.archiveStreamStartTimes(with: archiveShow) { [weak self] archiveStartDetails -> (Void) in
            self?.archiveShowStartTimes = archiveStartDetails
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archiveShowStartTimes?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let archiveShowStartTime = archiveShowStartTimes?[indexPath.row]
    
        let timeLabel = UILabel()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = archiveShowStartTime?.startTimeDisplay
        cell.contentView.addPinnedSubview(timeLabel)
        cell.contentView.backgroundColor = .gray
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedStartTime = archiveShowStartTimes?[indexPath.row] else { return }
        
        startTimesDelegate?.playShow(archiveShow: archiveShow, archiveShowStart: selectedStartTime)
        dismiss(animated: true, completion: nil)
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
