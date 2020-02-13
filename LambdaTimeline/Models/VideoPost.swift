//
//  VideoPost.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class VideoPost: NSObject {
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var latitude: Double?
    var longitude: Double?
    
    // Latitude
    // Longitude
    
    
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let longKey = "longitude"
    static private let latKey = "latitude"
    
    var title: String? {
        return comments.first?.text
    }
    
    init(title: String, mediaURL: URL, author: Author, timestamp: Date = Date(), latitude: Double? = nil, longitude: Double? = nil) {
        self.mediaURL = mediaURL
        self.mediaType = .video
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[VideoPost.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[VideoPost.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[VideoPost.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[VideoPost.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[VideoPost.commentsKey] as? [[String: Any]],
            let latitude = dictionary[VideoPost.latKey] as? Double?,
            let longitude = dictionary[VideoPost.longKey] as? Double? else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
    }
    
    var dictionaryRepresentation: [String : Any] {
        let dict: [String: Any] = [VideoPost.mediaKey: mediaURL.absoluteString,
                VideoPost.mediaTypeKey: mediaType.rawValue,
                VideoPost.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                VideoPost.authorKey: author.dictionaryRepresentation,
                VideoPost.timestampKey: timestamp.timeIntervalSince1970,
                VideoPost.latKey: latitude as Any,
                VideoPost.longKey: longitude as Any]
        
        return dict
    }
}
