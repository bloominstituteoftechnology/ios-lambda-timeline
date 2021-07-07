//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Bobby Keffury on 1/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import MapKit

class PostAnnotation: NSObject, Decodable {
    
    let location: String
    let author: String
    let longitude: Double
    let latitude: Double
    
    internal init(location: String, author: String, longitude: Double, latitude: Double) {
        self.location = location
        self.author = author
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension PostAnnotation: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        location
    }
    
    var subtitle: String? {
        author
    }
    
}
