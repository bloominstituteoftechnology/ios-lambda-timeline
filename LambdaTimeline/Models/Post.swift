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

struct Locations {
    static let discordLocation = CLLocationCoordinate2D(latitude: 37.76331329345703, longitude: -122.40142822265625)
}

class Post: NSObject {
    
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
        self.location = location ?? Locations.discordLocation
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
