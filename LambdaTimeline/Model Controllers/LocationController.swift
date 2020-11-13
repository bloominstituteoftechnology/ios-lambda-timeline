//
//  LocationController.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationController()
    fileprivate let locationManager = CLLocationManager()
    var geotagging: Bool = false
    var userLocation: CLLocationCoordinate2D?
    
    func getUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        userLocation = location.coordinate
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
