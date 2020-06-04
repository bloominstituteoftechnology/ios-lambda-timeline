//
//  Posts+MKAnnotation.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import MapKit

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D()
    }
}

extension VideoPost: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return CLLocationCoordinate2D()
    }
}
