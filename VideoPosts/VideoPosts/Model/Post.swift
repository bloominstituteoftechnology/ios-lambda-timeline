//
//  Post.swift
//  VideoPosts
//
//  Created by David Wright on 5/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import MapKit

class Post: NSObject {
    
    var postTitle: String
    var mediaURL: URL
    var ratio: CGFloat?
    let author: Author
    let timestamp: Date
    let location: CLLocationCoordinate2D
    
    init(postTitle: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author = Author.davidWright, timestamp: Date = Date(), location: CLLocationCoordinate2D? = nil) {
        self.postTitle = postTitle
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.author = author
        self.timestamp = timestamp
        self.location = location ?? Locations.defaultLocation
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}

struct Author: Equatable {
    let uid: String = UUID().uuidString
    let displayName: String
    
    static let davidWright = Author(displayName: "David Wright")
}

extension Post: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        location
    }
    
    var title: String? {
        postTitle
    }
    
    var subtitle: String? {
        "Author: \(author.displayName)"
    }
    
}
