//
//  PlaylistTableVC.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/15/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class PlaylistTableVC: UITableViewController {
    private let networkManager = NetworkManager()
    private var plays = [Play]()
    
    private var offset = 0
    private var isFetching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44.0
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.reuseIdentifier)
        tableView.register(PlaylistLoadingCell.self, forCellReuseIdentifier: PlaylistLoadingCell.reuseIdentifier)
        
        getPlays()
    }
    
    func getPlays() {
        guard !isFetching else { return }
        
        isFetching = true
        networkManager.getPlay(limit: 5, offset: offset) { result in
            switch result {
            case .success(let playResult):
                
                let deadlineTime = DispatchTime.now() + .seconds(2)
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    self.isFetching = false

                    if let plays = playResult?.plays {
                        self.plays.append(contentsOf: plays)
                        
                        self.tableView.reloadData()
                    }
                    
                    self.offset += 5
                }
            case .failure:
                break
            }
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? plays.count : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.reuseIdentifier, for: indexPath) as! PlaylistCell
            cell.configure(with: plays[indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistLoadingCell.reuseIdentifier, for: indexPath) as! PlaylistLoadingCell
            return cell
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 4) && !isFetching {
            getPlays()
        }
    }
}

private class PlaylistCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistCell"
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        constructSubviews()
        constructConstraints()
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
            [albumArtImageView.widthAnchor.constraint(equalToConstant: 250),
            albumArtImageView.heightAnchor.constraint(equalToConstant: 250)]
        )
    }
    
    func configure(with play: Play?) {
        albumArtImageView.fromURLSting(play?.imageURI, placeHolder: UIImage(named: "vinylPlaceHolder"))
        
        if let startTime = play?.airdate {
            timestampLabel.text = DateFormatter.displayFormatter.string(from: startTime)
        }

        songNameLabel.text = play?.song
        artistLabel.text = play?.artist
        albumLabel.text = play?.album
        releaseInfoLabel.text = play?.releaseDate
        djCommentsLabel.text = play?.comment
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

private class PlaylistLoadingCell: UITableViewCell {
    static let reuseIdentifier = "PlaylistLoadCell"

    private let activityIndicator = CustomActivityIndicator()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
        constructSubviews()
        constructConstraints()
    }
    
    func setupSubviews() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.showActivityLoading()
    }
    
    func constructSubviews() {
        contentView.addSubview(activityIndicator)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate(
            [activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)]
        )
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
