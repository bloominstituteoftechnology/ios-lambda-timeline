//
//  Video+MKAnnotation.swift
//  Video
//
//  Created by Wyatt Harrell on 5/7/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import Foundation
import MapKit

extension Video: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? {
        name
    }
    
    var subtitle: String? {
        author
    }
}
