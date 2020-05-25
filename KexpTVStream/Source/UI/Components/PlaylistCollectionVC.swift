//
//  PlaylistCollectionVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/17/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

protocol PlaylistDelegate: class {
    func didSelectPlay(play: Play)
}

class PlaylistCollectionVC: UICollectionViewController {
    fileprivate enum Style {
        static let cellWidth = CGFloat(300)
        static let cellHeight = CGFloat(550)
        static let albumArtSize = Style.cellWidth
    }
    
    private let layout = UICollectionViewFlowLayout()
    private let networkManager = NetworkManager()
    private var plays = [Play]()
    private var offset = 0
    private var archiveShowTime: Date?

    weak var playlistDelegate: PlaylistDelegate?

    init() {
        layout.minimumLineSpacing = 50
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.footerReferenceSize = CGSize(width: Style.cellWidth, height: Style.cellHeight)
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
        
        let liveLimitSize = 10
                
        let deadline = paging ? DispatchTime.now() + 2.0 : DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.networkManager.getPlay(limit: paging ? liveLimitSize : 1, offset: paging ? self.offset : 0) { [weak self] result in
                guard
                    case let .success(playResult) = result,
                    let plays = playResult?.plays
                else {
                    return
                }
                
                if paging {
                   self?.plays.append(contentsOf: plays)
                   self?.collectionView.reloadData()
                   self?.offset += liveLimitSize
                } else {
                    self?.addCurrentlyPlayingTrack(play: plays.first)
                }
            }
        }
    }
    
    private func getArchivePlayItem() {
        guard var playlistTime = archiveShowTime else { return }
        
        defer { self.archiveShowTime = playlistTime.addingTimeInterval(30) }
        
        networkManager.getPlay(airdateBefore: DateFormatter.requestFormatter.string(from: playlistTime)) { [weak self] result in
            guard
                case let .success(playResult) = result,
                let plays = playResult?.plays
            else {
                return
            }
                
            self?.addCurrentlyPlayingTrack(play: plays.first)
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
        return CGSize(width: Style.cellWidth, height: Style.cellHeight)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let previouslyFocusedIndexPath = context.previouslyFocusedIndexPath {
            let previousFocusCell = collectionView.cellForItem(at: previouslyFocusedIndexPath)
            previousFocusCell?.transform = .identity
        }

        if let nextFocusedIndexPath = context.nextFocusedIndexPath {
            let nextFocusCell = collectionView.cellForItem(at: nextFocusedIndexPath)
            nextFocusCell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
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
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let play = plays[indexPath.row]
        playlistDelegate?.didSelectPlay(play: play)
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
    
    let albumArtImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.NowPlaying.TimeStamp.font
        label.textColor = ThemeManager.NowPlaying.TimeStamp.textColor
        label.textAlignment = .left
        return label
    }()

    private let songNameLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.NowPlaying.Track.font
        label.textColor = ThemeManager.NowPlaying.Track.textColor
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.NowPlaying.Artist.font
        label.textColor = ThemeManager.NowPlaying.Artist.textColor
        label.textAlignment = .left
        return label
    }()
    
    private let albumLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.NowPlaying.Album.font
        label.textColor = ThemeManager.NowPlaying.Album.textColor
        label.textAlignment = .left
        return label
    }()
    
    private let releaseInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = ThemeManager.NowPlaying.Release.font
        label.textColor = ThemeManager.NowPlaying.Release.textColor
        return label
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        return view
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
    }
    
    func setupSubviews() {}
    
    func constructSubviews() {
        contentView.addPinnedSubview(overlayView)
        contentView.addSubview(contentStackView)
     
        contentStackView.addArrangedSubview(albumArtImageView)
        
        contentStackView.addArrangedSubview(trackDetailStackView)
        

        trackDetailStackView.addArrangedSubview(timestampLabel)
        trackDetailStackView.addArrangedSubview(songNameLabel)
        trackDetailStackView.addArrangedSubview(artistLabel)
        trackDetailStackView.addArrangedSubview(albumLabel)
        trackDetailStackView.addArrangedSubview(releaseInfoLabel)
        trackDetailStackView.addArrangedSubview(UIView())
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate(
            [albumArtImageView.widthAnchor.constraint(equalToConstant: PlaylistCollectionVC.Style.albumArtSize),
            albumArtImageView.heightAnchor.constraint(equalToConstant: PlaylistCollectionVC.Style.albumArtSize)]
        )
    }
    
    func configure(with play: Play?) {
        if let startTime = play?.airdate {
            timestampLabel.text = DateFormatter.displayFormatter.string(from: startTime)
        }
        
        if play?.playType == .airbreak {
            songNameLabel.text = "Air Break"
            albumArtImageView.image = UIImage(named: "vinylPlaceHolder")
            contentView.backgroundColor = .clear
        } else {
            if let imageURLString = play?.imageURI {
                albumArtImageView.fromURLSting(imageURLString, placeHolder:  UIImage(named: "vinylPlaceHolder")) { [weak self] image in
                    if imageURLString.isEmpty {
                        self?.contentView.backgroundColor = .clear
                    } else {
                        self?.contentView.backgroundColor = image?.averageColor
                    }
                }
            } else {
                contentView.backgroundColor = .clear
            }
            
            songNameLabel.text = play?.song
            artistLabel.text = play?.artist
            albumLabel.text = play?.album
            
            if
                let releaseDateString = play?.releaseDate,
                let releaseDate = DateFormatter.releaseFormatter.date(from: releaseDateString)
            {
                let releaseInfo = "\(DateFormatter.yearFormatter.string(from: releaseDate))"

                if let label = play?.labels?.first {
                    releaseInfoLabel.text = releaseInfo + " - \(label)"
                } else {
                    releaseInfoLabel.text = releaseInfo
                }
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

