//
//  SettingsViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/4/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class SettingsViewController: BaseViewController {
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var idleTimerSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        let font: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font: ThemeManager.Settings.font as Any]
        segmentedControl.setTitleTextAttributes(font, for: .normal)
        segmentedControl.insertSegment(withTitle: "Disabled", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "Enabled", at: 1, animated: true)
        segmentedControl.addTarget(self, action: #selector(idleTimerControlDidChange(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        idleTimerSegmentedControl.selectedSegmentIndex = UserSettingsManager.disableTimer == true ? 0 : 1
    }
    
    override func constructSubviews() {
        contentStackView.addArrangedSubview(SettingsRowView(title: "Idle Timer:", view: disableIdleTimerSegmentedControl))
        contentStackView.addArrangedSubview(SettingsRowView(title: "Version:", value: appVersion))
        contentStackView.addArrangedSubview(SettingsRowView(title: "Build:", value: appBuild))
        contentStackView.addArrangedSubview(SettingsRowView(title: "App Feedback: feedback@kexp.org"))
        contentStackView.addArrangedSubview(SettingsRowView(title: "Donate at kexp.org/donate"))
    }
    
    override func constructConstraints() {
        view.addSubview(contentStackView, constraints: [
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func idleTimerControlDidChange(_ sender: Any) {
        let isIdleTimerDisabled = idleTimerSegmentedControl.selectedSegmentIndex == 0
        AnalyticsManager.fire(.disableIdleTimer(isIdleTimerDisabled))
        
        UserSettingsManager.disableTimer = isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = isIdleTimerDisabled
    }
}

class SettingsRowView: UIView {
    private let rowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 250
        stackView.distribution = .fill
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = ThemeManager.Settings.font
        label.textColor = ThemeManager.Settings.textColor
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = ThemeManager.Settings.font
        label.textColor = ThemeManager.Settings.textColor
        label.textAlignment = .right
        return label
    }()
    
    init(title: String, value: String?) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        valueLabel.text = value
        addPinnedSubview(rowStackView)
        rowStackView.addArrangedSubview(titleLabel)
        rowStackView.addArrangedSubview(valueLabel)
    }
    
    init(title: String, view: UIView) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        addPinnedSubview(rowStackView)
        rowStackView.addArrangedSubview(titleLabel)
        rowStackView.addArrangedSubview(view)
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        titleLabel.textAlignment = .center
        addPinnedSubview(rowStackView)
        rowStackView.addArrangedSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
