//
//  ViewController.swift
//  Speed
//
//  Created by Chris Dzombak on 5/9/16.
//  Copyright © 2016 Chris Dzombak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var maxSpeedLabel: UILabel!

    var speedTracker: SpeedTracker!

    override func viewDidLoad() {
        super.viewDidLoad()

        formatAndUpdateLabels(currentSpeed: speedTracker.currentSpeed, maxSpeed: speedTracker.maxSpeed)

        NSNotificationCenter.defaultCenter().addObserverForName(SpeedTracker.Notifications.CurrentSpeedNotification.rawValue, object: speedTracker, queue: NSOperationQueue.mainQueue()) { [weak self] (notification: NSNotification) in

            guard let currentSpeedNumber = notification.userInfo?[SpeedTracker.Notifications.CurrentSpeed] as? NSNumber,
                maxSpeedNumber = notification.userInfo?[SpeedTracker.Notifications.MaxSpeed] as? NSNumber else {
                    fatalError()
            }

            self?.formatAndUpdateLabels(currentSpeed: currentSpeedNumber.doubleValue, maxSpeed: maxSpeedNumber.doubleValue)
        }
    }

    @IBAction func resetMaxSpeedTapped(sender: UIButton) {
        speedTracker.resetMaxSpeed()
    }

    private func formatAndUpdateLabels(currentSpeed currentSpeed: Double, maxSpeed: Double) {
        speedLabel.text = formatForCurrentLocale(speedInMetersPerSecond: currentSpeed)
        maxSpeedLabel.text = "Max. Speed: \(formatForCurrentLocale(speedInMetersPerSecond: maxSpeed))"
    }

}
