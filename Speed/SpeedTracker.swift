//
//  SpeedTracker.swift
//  Speed
//
//  Created by Chris Dzombak on 5/9/16.
//  Copyright © 2016 Chris Dzombak. All rights reserved.
//

import Foundation
import CoreLocation

class SpeedTracker: NSObject, CLLocationManagerDelegate {

    enum Notifications: String {
        case CurrentSpeedNotification

        static let CurrentSpeed = "SpeedTracker.CurrentSpeed"
        static let MaxSpeed = "SpeedTracker.MaxSpeed"
    }

    private(set) var currentSpeed: Double
    private(set) var maxSpeed: Double

    private let locationManager: CLLocationManager

    override init() {
        locationManager = CLLocationManager()
        currentSpeed = 0.0
        maxSpeed = 0.0

        super.init()

        restoreSpeeds()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func startTracking() {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func resetMaxSpeed() {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let `self` = self else { return }

            self.maxSpeed = 0.0
            self.updateSpeed(self.currentSpeed)
        }
    }

    private func updateSpeed(speedInMetersPerSecond: Double) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let `self` = self else { return }

            self.currentSpeed = max(0.0, speedInMetersPerSecond)
            self.maxSpeed = max(self.maxSpeed, self.currentSpeed)

            let userInfo = [
                Notifications.CurrentSpeed: NSNumber(double: self.currentSpeed),
                Notifications.MaxSpeed: NSNumber(double: self.maxSpeed),
            ]

            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.CurrentSpeedNotification.rawValue, object: self, userInfo: userInfo)

            self.saveSpeeds()
        }
    }

    // MARK: CLLocationManagerDelegate

    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        updateSpeed(lastLocation.speed)
    }
}

// MARK: Persistence

extension SpeedTracker {
    private enum Defaults: String {
        case CurrentSpeed = "SpeedTracker.CurrentSpeed"
        case MaxSpeed = "SpeedTracker.MaxSpeed"
    }

    func saveSpeeds() {
        let defaults = NSUserDefaults.standardUserDefaults()

        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) { 
            defaults.setDouble(self.currentSpeed, forKey: Defaults.CurrentSpeed.rawValue)
            defaults.setDouble(self.maxSpeed, forKey: Defaults.MaxSpeed.rawValue)
        }
    }

    func restoreSpeeds() {
        let defaults = NSUserDefaults.standardUserDefaults()

        currentSpeed = defaults.doubleForKey(Defaults.CurrentSpeed.rawValue)
        maxSpeed = defaults.doubleForKey(Defaults.MaxSpeed.rawValue)
    }
}
