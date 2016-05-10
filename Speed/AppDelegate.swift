//
//  AppDelegate.swift
//  Speed
//
//  Created by Chris Dzombak on 5/9/16.
//  Copyright © 2016 Chris Dzombak. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var speedTracker: SpeedTracker!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        speedTracker = SpeedTracker()

        guard let speedViewController = window?.rootViewController as? ViewController else { fatalError() }
        speedViewController.speedTracker = speedTracker

        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            guard let `self` = self else { return }
            self.startTrackingOrShowLocationAlert(self.speedTracker)
        }

        disableIdleTimerIfWanted()
        
        return true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        startTrackingOrShowLocationAlert(speedTracker)
        disableIdleTimerIfWanted()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        speedTracker.stopTracking()
    }

    private func startTrackingOrShowLocationAlert(tracker: SpeedTracker) {
        speedTracker.startTracking()

        let locationPermissions = CLLocationManager.authorizationStatus()
        if locationPermissions == .Restricted || locationPermissions == .Denied {
            let alertController = UIAlertController(title: "Location Services Required", message: "Location services must be enabled for this app, and turned on in Settings, in order to display your speed.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

            window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    private func disableIdleTimerIfWanted() {
        let settingsWantsScreenDimmingDisabled =  NSUserDefaults.standardUserDefaults().boolForKey("Speed.KeepScreenAwake")
        UIApplication.sharedApplication().idleTimerDisabled = settingsWantsScreenDimmingDisabled
    }
}

