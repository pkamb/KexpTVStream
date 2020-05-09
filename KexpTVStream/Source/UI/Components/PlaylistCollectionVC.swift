//
//  PlaylistCollectionVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/17/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class PlaylistCollectionVC: UICollectionViewController {
    private let layout = UICollectionViewFlowLayout()
    private let networkManager = NetworkManager()
    private var plays = [Play]()
    private var offset = 0
    private var archiveShowTime: Date?

    init() {
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = CGSize(width: 300, height: 450)
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseIdentifier)
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { [weak self] _ in
            if self?.archiveShowTime == nil {
                self?.getPlays(paging: false)
            } else {
                self?.getArchivePlayItem()
            }
        })
        
        getPlays(paging: true)
    }

    func updateArchievePlaylistShowTime(startTime: Date?) {
        archiveShowTime = startTime
        plays.removeAll()
        collectionView.reloadData()
        getArchivePlayItem()
    }
    
    func livePlaylistShowTime() {
        archiveShowTime = nil
        plays.removeAll()
        getPlays(paging: true)
    }
    
    private func getPlays(paging: Bool) {
        if paging, offset > 100 { return }
                
        let deadline = paging ? DispatchTime.now() + 2.0 : DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.networkManager.getPlay(limit: paging ? 5 : 1, offset: paging ? self.offset : 0) { [weak self] result in
                guard case let .success(playResult) = result else { return }
 
                DispatchQueue.main.async {
                    guard let plays = playResult?.plays else { return }
                    
                    if paging {
                       self?.plays.append(contentsOf: plays)
                       self?.collectionView.reloadData()
                       self?.offset += 5
                    } else {
                        self?.addCurrentlyPlayingTrack(play: plays.first)
                    }
                }
            }
        }
    }
    
    private func getArchivePlayItem() {
        guard var playlistTime = archiveShowTime else { return }
        
        defer { self.archiveShowTime = playlistTime.addingTimeInterval(30) }
        
        networkManager.getPlay(airdateBefore: DateFormatter.requestFormatter.string(from: playlistTime)) { [weak self] result in
            guard case let .success(playResult) = result else { return }
            
            DispatchQueue.main.async {
                guard let plays = playResult?.plays else { return }
                self?.addCurrentlyPlayingTrack(play: plays.first)
           }
        }
    }
    
    private func addCurrentlyPlayingTrack(play: Play?) {
        guard let recentlyReceivedPlay = play else { return }
        
        if plays.first?.id != recentlyReceivedPlay.id {
            plays.insert(recentlyReceivedPlay, at: 0)
            collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        }
    }
}

extension PlaylistCollectionVC: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plays.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.reuseIdentifier, for: indexPath as IndexPath) as! PlaylistCell
        
        cell.configure(with: plays[indexPath.row])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 450)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = collectionView.cellForItem(at: previouslyFocusedIndexPath)
            previousFocusCell?.transform = .identity
        }

        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = collectionView.cellForItem(at: nextFocusedIndexPath)
            nextFocusCell?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard archiveShowTime == nil else { return }
        
        if indexPath.row + 1 == plays.count {
            getPlays(paging: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        
        guard archiveShowTime == nil, footerView.subviews.isEmpty else {
            if offset >= 100 || archiveShowTime != nil  {
                footerView.subviews.forEach { $0.removeFromSuperview() }
            }
            
            return footerView
        }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        footerView.addSubview(activityIndicator)
        activityIndicator.centerXAnchor.constraint(equalTo: footerView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
         
        return footerView
    }
}

private class PlaylistCell: UICollectionViewCell {
    static let reuseIdentifier = "PlaylistCell"
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let trackDetailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let djCommentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private let albumArtImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private let albumLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private let releaseInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    private let djCommentsTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.text = "DJ COMMENTS"
        return label
    }()
    
    private let djCommentsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        setupSubviews()
        constructSubviews()
        constructConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        songNameLabel.text = nil
        artistLabel.text = nil
        albumLabel.text = nil
        releaseInfoLabel.text = nil
        djCommentsLabel.text = nil
    }
    
    func setupSubviews() {}
    
    func constructSubviews() {
        contentView.addPinnedSubview(contentStackView)
        contentStackView.addArrangedSubview(albumArtImageView)
        
        contentStackView.addArrangedSubview(trackDetailStackView)
        trackDetailStackView.addArrangedSubview(timestampLabel)
        trackDetailStackView.addArrangedSubview(songNameLabel)
        trackDetailStackView.addArrangedSubview(artistLabel)
        trackDetailStackView.addArrangedSubview(albumLabel)
        trackDetailStackView.addArrangedSubview(releaseInfoLabel)
        
        contentStackView.addArrangedSubview(djCommentsStackView)
        djCommentsStackView.addArrangedSubview(djCommentsTitleLabel)
        djCommentsStackView.addArrangedSubview(djCommentsLabel)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [albumArtImageView.widthAnchor.constraint(equalToConstant: 300),
            albumArtImageView.heightAnchor.constraint(equalToConstant: 300)]
        )
    }
    
    func configure(with play: Play?) {
        albumArtImageView.fromURLSting(play?.imageURI, placeHolder: UIImage(named: "vinylPlaceHolder"))
        
        if let startTime = play?.airdate {
            timestampLabel.text = DateFormatter.displayFormatter.string(from: startTime)
        }
        
        if play?.playType == .airbreak {
            songNameLabel.text = "Air Break"
        } else {
            songNameLabel.text = play?.song
            artistLabel.text = play?.artist
            albumLabel.text = play?.album
            releaseInfoLabel.text = play?.releaseDate
            djCommentsLabel.text = play?.comment
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

