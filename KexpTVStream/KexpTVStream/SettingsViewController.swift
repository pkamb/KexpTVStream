//
//  SettingsViewController.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/4/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

class SettingsViewController: UIViewController {
    @IBOutlet weak var disableIdleTimerSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundLayer = KexpStyle.kexpBackgroundGradient()
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, at: 0)
        
        disableIdleTimerSegmentedControl.selectedSegmentIndex = UserSettingsManager.disableTimer == true ? 0 : 1
    }
    
    @IBAction func doneAction(_ sender: Any) {
        let isDisplayTimerIdle = disableIdleTimerSegmentedControl.selectedSegmentIndex == 0 ? true : false
        UserSettingsManager.disableTimer = isDisplayTimerIdle
        UIApplication.shared.isIdleTimerDisabled = isDisplayTimerIdle
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
