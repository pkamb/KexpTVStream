//
//  DJViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/18/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class DJViewController: UIViewController {
    private let networkManager = NetworkManager()
    private var currentShow: Show?
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        return stackView
    }()
    
    private let hostArtImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 100
        return imageView
    }()
    
    private let onAirStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let onAirLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.text = "ON AIR"
        return label
    }()

    private let showDetailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        constructSubviews()
        constructConstraints()
        updateShowDetails()
    }
    
    func updateShowDetails() {
        networkManager.getShow { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let shows):
                DispatchQueue.main.async {
                    strongSelf.populateShowDetail(show: shows?.shows?.first)
                }

            case .failure: break
            }
        }
    }
    
    func setupSubviews() {
    }
    
    func constructSubviews() {
        view.addPinnedSubview(contentStackView)
        contentStackView.addArrangedSubview(hostArtImageView)
        contentStackView.addArrangedSubview(onAirStackView)
        onAirStackView.addArrangedSubview(onAirLabel)
        onAirStackView.addArrangedSubview(showDetailsLabel)
    }
    
    func constructConstraints() {
        NSLayoutConstraint.activate([
            hostArtImageView.heightAnchor.constraint(equalToConstant: 200),
            hostArtImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        contentStackView.setCustomSpacing(50, after: hostArtImageView)
    }
    
    func populateShowDetail(show: Show?) {
        hostArtImageView.fromURLSting(show?.imageURI)
        showDetailsLabel.text = "\(show?.programName ?? "") with \(show?.hostNames?.first ?? "")"
    }
}
