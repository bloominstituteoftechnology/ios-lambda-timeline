//
//  Tag.swift
//  GeoTags
//
//  Created by Chris Gonzales on 4/9/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import MapKit

class Tag: NSObject {
    let longitude: Double
    let latitude: Double
    
    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension Tag: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }
    
    var title: String? {
        "Current Location"
    }
    // can add title and subtitle later
}



