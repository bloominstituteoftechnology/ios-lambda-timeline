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
    
    static private let urlKey = "url"
    static private let textKey = "text"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let text: String?
    let author: Author
    let timestamp: Date
    let audioURL: URL?
    
    init(text: String, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.audioURL = nil
    }
    
    init?(dictionary: [String : Any]) {
        guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
            
            if let text = dictionary[Comment.textKey] as? String {
                self.text = text
                self.audioURL = nil
        } else if let urlString = dictionary[Comment.urlKey] as? String, let url = URL(string: urlString) {
            self.audioURL = url
            self.text = nil
        } else {
            return nil
        }
            self.author = author
            self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        }
        
    init(url: URL, author: Author, timestamp: Date = Date()) {
        self.audioURL = url
        self.author = author
        self.timestamp = timestamp
        self.text = nil
    }
        
    var dictionaryRepresentation: [String: Any] {
        if let text = text {
        return [Comment.textKey: text,
                    Comment.author: author.dictionaryRepresentation,
                    Comment.timestampKey: timestamp.timeIntervalSince1970]
        
    }  else if let urlString = audioURL?.absoluteString {
        return [Comment.urlKey: urlString,
                        Comment.author: author.dictionaryRepresentation,
                        Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
        return [:]
    }
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
