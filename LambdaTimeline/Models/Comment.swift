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
    static private let audioURLKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let text: String?
    let audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.audioURL = nil
        self.author = author
        self.timestamp = timestamp
    }
    
    init(audioURL: URL, author: Author, timestamp: Date = Date()) {
        self.text = nil
        self.audioURL = audioURL
        self.author = author
        self.timestamp = timestamp
    }
    
    init?(dictionary: [String : Any]) {
        guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
        
        if let text = dictionary[Comment.textKey] as? String {
            self.text = text
            self.audioURL = nil
        } else if let audioURL = dictionary[Comment.audioURLKey] as? URL {
            self.text = nil
            self.audioURL = audioURL
        } else {
            return nil
        }
        
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        var dictionary: [String: Any] = [Comment.author: author.dictionaryRepresentation,
                                         Comment.timestampKey: timestamp.timeIntervalSince1970]
        
        if let text = text {
            dictionary[Comment.textKey] = text
        } else if let audioURL = audioURL {
            dictionary[Comment.audioURLKey] = audioURL
        }
        
        return dictionary
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
