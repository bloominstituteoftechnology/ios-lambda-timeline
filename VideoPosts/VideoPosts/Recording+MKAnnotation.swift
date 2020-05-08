//
//  Recording+MKAnnotation.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 08/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import MapKit

extension Recording: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 51.536600, longitude: 0.052830)
    }

    var title: String? {
        return recordingTitle
    }

    var subtitle: String? {
        return "Tobi"
    }
}
