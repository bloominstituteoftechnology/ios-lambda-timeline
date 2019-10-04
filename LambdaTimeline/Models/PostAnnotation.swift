//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import MapKit
class PostAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: post.latitude!, longitude: post.longitude!)
    }
    
    var title: String? {
        post.title
    }
    var subtitle: String? {
        post.author.displayName
    }
    let post: Post
    
    init(post: Post) {
        self.post = post
    }
}
