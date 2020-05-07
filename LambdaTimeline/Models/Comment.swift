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
    
    init(text: String?, audio: URL?, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.audioURL = audio
    }
    
    init?(dictionary: [String : Any]) {
        if dictionary[Comment.audioURLKey] == nil {
            text = dictionary[Comment.textKey] as? String
            let authorDictionary = dictionary[Comment.author]
            author = Author(dictionary: authorDictionary as! [String : Any])!
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? Date
            
        } else {
            text = dictionary[Comment.textKey] as! String?
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            author = Author(dictionary: authorDictionary!)
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval
            audioURL = dictionary[Comment.audioURLKey] as? URL
        }
        
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970,
                Comment.audioURLKey: audioURL]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
