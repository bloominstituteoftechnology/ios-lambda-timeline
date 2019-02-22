//
//  PostAnnotation.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class PostAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var post: Post
    
    init(post: Post){
        self.coordinate = post.geotag!
        self.post = post
        super.init()
    }
}
