//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_204 on 1/16/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import MapKit

class PostAnnotation: NSObject, MKAnnotation {

    let post: Post

    init(post: Post) {
        self.post = post
    }

    var coordinate: CLLocationCoordinate2D {
        guard let geotag = post.geotag else {
            return CLLocationCoordinate2D()
        }
        return geotag
    }

    var title: String? {
        post.title
    }

    var subtitle: String? {
        post.author.displayName
    }

}
