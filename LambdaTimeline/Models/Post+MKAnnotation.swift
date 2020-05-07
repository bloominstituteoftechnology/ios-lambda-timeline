//
//  Post+MKAnnotation.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import MapKit

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        guard let geotag = geotag else { return CLLocationCoordinate2D() }
        return geotag
    }

    var title: String? {
        self.comments[0].text
    }

    var subtitle: String? {
        self.author.displayName
    }
}
