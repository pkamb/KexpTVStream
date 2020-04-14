//
//  ArchiveDetailCollectionView.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/12/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower
import UIKit

class ArchiveDetailCollectionView: UICollectionView {
    fileprivate enum Layout {
        static let hostCellHeight: CGFloat = 200
        static let showCellHeight: CGFloat = 200
        static let genreCellHeight: CGFloat = 100
        static let imageSize: CGFloat = 150
    }
    
    enum ArchiveType {
        case host
        case show
        case genre
    }
    
    private let layout = UICollectionViewFlowLayout()
    private var archiveType: ArchiveType
    private var archieveShows: [[String: [ArchiveShow]]]?

    init(with archiveType: ArchiveType) {
        self.archiveType = archiveType
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        super.init(frame: CGRect.zero, collectionViewLayout: layout)

        translatesAutoresizingMaskIntoConstraints = false
        register(ArchiveDetailCollectionCell.self, forCellWithReuseIdentifier: ArchiveDetailCollectionCell.reuseIdentifier)
        
        dataSource = self
        delegate = self
        
        backgroundColor = .white
    }
    
    func configure(with archieveShows: [[String: [ArchiveShow]]]) {
        self.archieveShows = archieveShows
        reloadData()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension ArchiveDetailCollectionView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return archieveShows?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArchiveDetailCollectionCell.reuseIdentifier, for: indexPath as IndexPath) as! ArchiveDetailCollectionCell
        
        let archiveDictionary = archieveShows?[indexPath.row]
        cell.configure(type: archiveType, archiveDictionary: archiveDictionary)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let containerWidth = superview?.frame.width else { return CGSize.zero }

        let cellWidth = containerWidth/3.0
    
        return CGSize(width: cellWidth, height: getCellHeight())
    }
    
    private func getCellHeight() -> CGFloat {
        switch archiveType {
        case .genre: return Layout.genreCellHeight
        case .host: return Layout.hostCellHeight
        case .show: return Layout.showCellHeight
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = collectionView.cellForItem(at: previouslyFocusedIndexPath)
            previousFocusCell?.contentView.backgroundColor = .gray
        }

        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = collectionView.cellForItem(at: nextFocusedIndexPath)
            nextFocusCell?.contentView.backgroundColor = UIColor.white
        }
    }
}

private class ArchiveDetailCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "DetailCell"
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
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
        return label
    }()

    private let middleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let archiveImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .yellow
        imageView.layer.cornerRadius = ArchiveDetailCollectionView.Layout.imageSize / 2
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
        contentView.backgroundColor = .gray
    }
    
    func configure(type: ArchiveDetailCollectionView.ArchiveType, archiveDictionary: [String: [ArchiveShow]]?) {
        let archiveShow = archiveDictionary?.values.first?.first?.show
        
        switch type {
        case .host:
            archiveImageView.fromURLSting(archiveShow?.imageURI)
            topLabel.text = archiveShow?.hostNames?.first
            middleLabel.text = archiveShow?.programName
            bottomLabel.text = archiveShow?.programTags
            
        case .show:
            archiveImageView.fromURLSting(archiveShow?.imageURI)
            topLabel.text = archiveShow?.programName
            middleLabel.text = archiveShow?.hostNames?.first
            bottomLabel.text = archiveShow?.programTags
            
        case .genre:
            topLabel.text = archiveShow?.programTags
            archiveImageView.removeFromSuperview()
        }
    }
    
    private func constructSubviews() {
        contentView.addSubview(contentStackView)
        contentStackView.addArrangedSubview(archiveImageView)
        contentStackView.addArrangedSubview(labelStackView)
        
        labelStackView.addArrangedSubview(topLabel)
        labelStackView.addArrangedSubview(middleLabel)
        labelStackView.addArrangedSubview(bottomLabel)
    }
    
    private func constructConstraints() {
        NSLayoutConstraint.activate(
            [contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
             contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
             contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20.0),
             contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        
        NSLayoutConstraint.activate([
            archiveImageView.heightAnchor.constraint(equalToConstant: ArchiveDetailCollectionView.Layout.imageSize),
            archiveImageView.widthAnchor.constraint(equalToConstant: ArchiveDetailCollectionView.Layout.imageSize)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
