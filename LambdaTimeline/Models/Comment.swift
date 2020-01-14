//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

enum CommentType {
    case text
    case audio
}

class Comment: FirebaseConvertible, Equatable {
    static private let textKey = "text"
    static private let audioKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"

    let text: String?
    let audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String, author: Author, timestamp: Date = Date()) {
        self.audioURL = nil
        self.text = text
        self.author = author
        self.timestamp = timestamp
    }

    init(audioURL: URL, author: Author, timestamp: Date = Date()) {
        self.audioURL = audioURL
        self.text = nil
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval
            else { return nil }
        let text = dictionary[Comment.textKey] as? String
        let audioURL = dictionary[Comment.audioKey] as? URL
        
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
