//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    static private let isTextCommentKey = "isTextComment"
    static private let audioURLKey = "audioURL"
    
    let text: String
    let author: Author
    let timestamp: Date
    let isTextComment: Bool
    let audioURL: URL?
    
    init(text: String, author: Author, isTextComment: Bool = true, audioURL: URL? = nil, timestamp: Date = Date()) {
        self.text = text
        self.author = author
        self.isTextComment = isTextComment
        self.audioURL = audioURL
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval,
            let isTextComment = dictionary[Comment.isTextCommentKey] as? Bool,
            let audioURL = dictionary[Comment.audioURLKey] as? URL?
            else { return nil }
        
        self.text = text
        self.author = author
        self.isTextComment = isTextComment
        self.audioURL = audioURL
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.isTextCommentKey: isTextComment,
                Comment.audioURLKey: audioURL,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
