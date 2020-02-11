//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-16.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    unowned var post: Post
    var coordinate: CLLocationCoordinate2D { post.geotag! }

    init?(post: Post) {
        guard post.geotag != nil else { return nil }
        self.post = post

        super.init()
    }
}
