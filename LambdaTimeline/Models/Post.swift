//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import MapKit

enum MediaType: String {
    case image
}

struct Post {
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date(), geotag: CLLocationCoordinate2D? = CLLocationCoordinate2D() ) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.geotag = geotag
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]],
            let latitude = dictionary[Post.geotagLatitudeKey] as? Double,
            let longitude = dictionary[Post.geotagLongitudeKey] as? Double else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        self.geotag?.latitude = latitude
        self.geotag?.longitude = longitude
    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970,
                Post.geotagLatitudeKey: geotag?.latitude ?? 0.0,
                Post.geotagLongitudeKey: geotag?.longitude ?? 0.0]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var ratio: CGFloat?
    var geotag: CLLocationCoordinate2D?
    
    var title: String? {
        return comments.first?.text
    }
    
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let geotagLatitudeKey = "latitude"
    static private let geotagLongitudeKey = "longitude"
}

class PostAnnotation: NSObject, MKAnnotation {
    init(post: Post) {
        self.post = post
    }
    
    var post: Post?
    var coordinate: CLLocationCoordinate2D {
        if let post = post {
            return CLLocationCoordinate2D(latitude: post.geotag?.latitude ?? 0.0,
                                          longitude: post.geotag?.longitude ?? 0.0)
        }
        preconditionFailure("No post provided for annotation.")
    }
    
    private var title: String? {
        if let post = post {
            return post.title
        }
        preconditionFailure("No post provided for annotation.")
    }
    
    var subtitle: String? {
        if let post = post {
            return "Author: \(post.author)"
        }
        preconditionFailure("No post provided for annotation.")
    }
}
