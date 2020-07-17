//
//  Post.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/16/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import Foundation
import MapKit

class Post: NSObject {
    
    var postTitle: String
    var mediaURL: URL
    var ratio: CGFloat?
    let author: Author
    let timestamp: Date
    let location: CLLocationCoordinate2D
    var image: UIImage
    
    init(postTitle: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author = Author.claudiaMaciel, timestamp: Date = Date(), location: CLLocationCoordinate2D? = nil, image: UIImage) {
        self.postTitle = postTitle
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.author = author
        self.timestamp = timestamp
        self.location = location ?? Locations.defaultLocation
        self.image = image
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}

struct Author: Equatable {
    let uid: String = UUID().uuidString
    let displayName: String
    
    static let claudiaMaciel = Author(displayName: "Claudia Maciel")
}

struct Locations {
    static let defaultLocation = CLLocationCoordinate2D(latitude: 36.670963, longitude: -121.818290)
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
