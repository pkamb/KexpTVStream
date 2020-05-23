//
//  DJViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/18/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class DJViewController: UIViewController {
    typealias Completion = () -> Void
    
    var currentlyPlayingArchiveShow: ArchiveShow?
    
    private let networkManager = NetworkManager()
    private var currentShow: Show?
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private let hostArtImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 75
        return imageView
    }()

    private let showDetailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
        label.font = ThemeManager.ShowDetails.font
        label.textColor = ThemeManager.ShowDetails.textColor
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { [weak self] _ in
            self?.updateShowDetails()
        })
        
        constructSubviews()
        constructConstraints()
    }
    
    func updateShowDetails(completion: Completion? = nil) {
        if let showId = currentlyPlayingArchiveShow?.show.id {
            updateArchiveShowDetails(with: String(showId), completion: completion)
        } else {
            updateLiveShowDetails(completion: completion)
        }
    }
    
    private func updateLiveShowDetails(completion: Completion? = nil) {
        networkManager.getShow { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let shows):
                DispatchQueue.main.async {
                    strongSelf.populateShowDetail(show: shows?.shows?.first)
                }

            case .failure:
                DispatchQueue.main.async {
                    strongSelf.showNotFound()
                }
            }
            
            completion?()
        }
    }
    
    private func updateArchiveShowDetails(with showId: String, completion: Completion? = nil) {
        networkManager.getShowDetails(with: showId) { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let show):
                DispatchQueue.main.async {
                    strongSelf.populateShowDetail(show: show)
                }

            case .failure:
                DispatchQueue.main.async {
                    strongSelf.showNotFound()
                }
            }
            
            completion?()
        }
    }
    
    func constructSubviews() {
        view.addPinnedSubview(contentStackView, insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
        contentStackView.addArrangedSubview(hostArtImageView)
        contentStackView.addArrangedSubview(showDetailsLabel)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate([
            hostArtImageView.heightAnchor.constraint(equalToConstant: 150),
            hostArtImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    func populateShowDetail(show: Show?) {
        hostArtImageView.fromURLSting(show?.imageURI, completion: { [weak self] image in
            self?.view.backgroundColor = .white
        })
        
        if
            let programName = show?.programName,
            let hostNames = show?.hostNames?.joined(separator: ", ")
        {
            let showDetails = programName + " with \(hostNames)"
            showDetailsLabel.text = showDetails
        } else {
            showDetailsLabel.text = "Unknown"
        }
    }
    
    private func showNotFound() {
        hostArtImageView.image = nil
        showDetailsLabel.text = "Unknown"
    }
}
