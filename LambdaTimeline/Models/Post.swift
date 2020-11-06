//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit

enum MediaType {
    case image(UIImage)
}

class Post: NSObject {
    
    struct Locations {
        static let currentLocation = CLLocationCoordinate2D(latitude: 32.8844 , longitude: 117.2390)
    }
    
    let mediaType: MediaType
    let author: String
    let timestamp: Date
    var comments: [Comment]
    var ratio: CGFloat?
    var id: String?
    let location: CLLocationCoordinate2D
    
    var title: String? {
        comments.first?.text
    }
    
    var audioURL: URL? {
        comments.first?.audioURL
    }
    
    init(title: String, mediaType: MediaType, ratio: CGFloat?, author: String, timestamp: Date = Date(), audioURL: URL?, location: CLLocationCoordinate2D? = nil) {
        self.mediaType = mediaType
        self.ratio = ratio
        self.author = author
        self.comments = [Comment(text: title, author: author, audioURL: audioURL)]
        self.timestamp = timestamp
        self.id = UUID().uuidString
        self.location = location ?? Locations.currentLocation
    }
    
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    var postTitle: String? { title }
    var subtitle: String? { author }
    
    
}
