//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

enum CommentType: String {
    case text
    case audio
}

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    static private let audioURL = "audioURL"
    static private var type = "type"
    
    let text: String?
    let author: Author
    let timestamp: Date
    var audioURL: URL?
    var type: CommentType
    
    init(text: String, author: Author, timestamp: Date = Date(), type: CommentType) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.type = type
    }
    
    init?(dictionary: [String : Any]) {
        guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
            let audioURL = dictionary[Comment.audioURL] as? URL,
            let type = dictionary[Comment.type] as? CommentType else { return nil }
        
        self.text = text
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.audioURL = audioURL
        self.type = type
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        return [Comment.textKey: text as Any,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970,
                Comment.audioURL: audioURL as Any]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
