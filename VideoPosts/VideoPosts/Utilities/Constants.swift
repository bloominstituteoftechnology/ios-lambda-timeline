//
//  Constants.swift
//  VideoPosts
//
//  Created by David Wright on 5/12/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation
import MapKit

struct SegueIdentifiers {
    static let showCamera = "ShowCamera"
    static let showMapView = "ShowMapView"
}

struct ReuseIdentifiers {
    static let postCell = "PostCell"
    static let annotationReuseIdentifier = "PostAnnotationView"
}

struct Locations {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 39.916, longitude: -75.0035)
}
