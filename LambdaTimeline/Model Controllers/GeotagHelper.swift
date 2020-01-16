//
//  GeotagHelper.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreLocation

class GeotagHelper: NSObject {
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = 30
        manager.distanceFilter = 30
        manager.activityType = .other
        return manager
    }()

    var delegate: CLLocationManagerDelegate? {
        get {
            locationManager.delegate
        } set {
            locationManager.delegate = newValue
        }
    }

    var canRequestLocation: Bool {
        var currentAuth = CLLocationManager.authorizationStatus()
        if currentAuth == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            currentAuth = CLLocationManager.authorizationStatus()
        }

        switch currentAuth {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            print("Denied, restricted, or unknown case")
            return false
        }
    }
}
