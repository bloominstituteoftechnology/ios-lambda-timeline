//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init?(post: Post) {
        guard let geotag = post.geotag else { return nil }
        
        coordinate = geotag
        title = post.title
        subtitle = post.author.displayName
    }
}
