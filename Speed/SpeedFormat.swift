//
//  SpeedFormat.swift
//  Speed
//
//  Created by Chris Dzombak on 5/9/16.
//  Copyright © 2016 Chris Dzombak. All rights reserved.
//

import Foundation

func formatForCurrentLocale(speedInMetersPerSecond speed: Double) -> String {
    guard let metricNumber = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem) as? NSNumber else { fatalError() }
    let useMetric = metricNumber.boolValue

    if useMetric {
        let convertedSpeed = round(speed * 3.6)
        let speedString = String(format: "%.0f", convertedSpeed)
        return "\(speedString) km/h"
    } else {
        let convertedSpeed = round(speed * 2.23694)
        let speedString = String(format: "%.0f", convertedSpeed)
        return "\(speedString) mph"
    }
}
