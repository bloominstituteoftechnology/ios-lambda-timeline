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
    case video
}

class Post {

    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let latitudeKey = "latitude"
    static private let longitudeKey = "longitude"
    static private let idKey = "id"

    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var geotag: CLLocationCoordinate2D?
    var ratio: CGFloat?

    var title: String? {
        return comments.first?.text
    }
    
    init(title: String, mediaURL: URL, mediaType: MediaType, geotag: CLLocationCoordinate2D?, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date()) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = mediaType
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.geotag = geotag
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]]
            else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id

        if let latitude = dictionary[Post.latitudeKey] as? Double,
            let longitude = dictionary[Post.longitudeKey] as? Double {
            self.geotag = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.geotag = nil
        }

    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970,
                Post.longitudeKey: geotag?.longitude ?? 0,
                Post.latitudeKey: geotag?.latitude ?? 0]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }
}
