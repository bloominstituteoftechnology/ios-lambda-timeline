//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreLocation

enum MediaType: String {
    case image
    case audioComment
    case video
}

enum LatLongType: Double {
    case latitude
    case longitude
}

class Post {
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author, geotag: CLLocationCoordinate2D? = nil, timestamp: Date = Date()) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.comments = [Comment(text: title, author: author, audioURL: nil)]
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
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]] else { return nil }
        var geotag: CLLocationCoordinate2D?
        if let geotagDictionary = dictionary[Post.geotagKey] as? [String: Any],
            let latitude = geotagDictionary["latitude"] as? Double,
            let longitude = geotagDictionary["longitude"] as? Double{
            
            geotag = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            geotag = nil
        }
        
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        self.geotag = geotag
    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970]
        
        if let ratio = self.ratio {
            dict[Post.ratioKey] = ratio
        }
        
        if let geotag = self.geotag {
            dict[Post.geotagKey] = [LatLongType.latitude: geotag.latitude, LatLongType.longitude: geotag.longitude]
        }
        
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
    static private let geotagKey = "geotag"
}
