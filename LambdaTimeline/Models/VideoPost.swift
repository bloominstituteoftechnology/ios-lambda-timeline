//
//  VideoPost.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class VideoPost {
    
       var mediaURL: URL
       let mediaType: MediaType
       let author: Author
       let timestamp: Date
       var comments: [Comment]
       var id: String?
       var ratio: CGFloat?
    
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
    
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date()) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[VideoPost.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[VideoPost.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[VideoPost.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[VideoPost.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[VideoPost.commentsKey] as? [[String: Any]] else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[VideoPost.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
    }

    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [VideoPost.mediaKey: mediaURL.absoluteString,
                VideoPost.mediaTypeKey: mediaType.rawValue,
                VideoPost.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                VideoPost.authorKey: author.dictionaryRepresentation,
                VideoPost.timestampKey: timestamp.timeIntervalSince1970]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[VideoPost.ratioKey] = ratio
        
        return dict
    }
    
    
    
    
}
