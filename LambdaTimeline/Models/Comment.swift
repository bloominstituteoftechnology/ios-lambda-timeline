//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

enum CommentContent {
    case text(String)
    case audio(URL)
}

class Comment: FirebaseConvertible, Equatable {
    static private let textKey = "text"
    static private let audioKey = "audio"
    static private let author = "author"
    static private let timestampKey = "timestamp"

    var content: CommentContent
    var text: String? {
        if case .text(let text) = content {
            return text
        } else { return nil }
    }
    var audioURL: URL? {
        if case .audio(let url) = content {
            return url
        } else { return nil }
    }
    let author: Author
    let timestamp: Date
    
    init(text: String, author: Author, timestamp: Date = Date()) {
        self.content = .text(text)
        self.author = author
        self.timestamp = timestamp
    }

    init(audioURL: URL, author: Author, timestamp: Date = Date()) {
        self.content = .audio(audioURL)
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard
            let authorDictionary = dictionary[Comment.author]
                as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey]
                as? TimeInterval
            else { return nil }

        if let text = dictionary[Comment.textKey] as? String, !text.isEmpty {
            self.content = .text(text)
        } else if let audioURLString = dictionary[Comment.audioKey] as? String,
            let url = URL(string: audioURLString) {
            self.content = .audio(url)
        } else {
            return nil
        }

        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text as Any,
                Comment.audioKey: audioURL?.absoluteString as Any,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
