//
//  LocationManager.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import CoreLocation

class LocationHelper {
    
    init(){
        locationManager.requestWhenInUseAuthorization()
    }
    
    let locationManager = CLLocationManager()
    
    func fetchUsersLocation() -> CLLocationCoordinate2D? {
        
        return locationManager.location?.coordinate
        
    }
}
