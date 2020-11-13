//
//  Annotation.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class Annotation: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var date: Date
    var image: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, date: Date, image: UIImage?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.image = image
    }
    
}
