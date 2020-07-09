//
//  LocationManager.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/27/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocationCoordinate2D?
    
    var shouldSendGeotag: Bool = true
    var currentLocation: CLLocationCoordinate2D? {
        get {
            return shouldSendGeotag ? self.lastLocation : nil
        }
    }
    
    func setUp() {
        self.locationManager.delegate = self
        
        locationManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        self.lastLocation = location?.coordinate
    }
}
