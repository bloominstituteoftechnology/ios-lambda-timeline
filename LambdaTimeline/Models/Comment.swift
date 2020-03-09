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
    static private let audioURLKey = "audioURL"
    
    let text: String?
    let author: Author
    let timestamp: Date
    let audioURL: URL?
    
    init(text: String?, author: Author, timestamp: Date = Date(), audioURL: URL?) {
        guard let text = text else {
            self.audioURL = audioURL
            self.text = nil
            self.author = author
            self.timestamp = timestamp
            return
        }
        self.text = text
        self.audioURL = nil
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
        } else if let audioURLString = dictionary[Comment.audioURLKey] as? String {
            self.audioURL = URL(string: audioURLString)!
            self.text = nil
        } else {
            return nil
        }
        
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        guard let text = text else {
            guard let audioURLString = audioURL?.absoluteString else { return [:] }
            return [Comment.audioURLKey: audioURLString,
                    Comment.author: author.dictionaryRepresentation,
                    Comment.timestampKey: timestamp.timeIntervalSince1970]
        }
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
