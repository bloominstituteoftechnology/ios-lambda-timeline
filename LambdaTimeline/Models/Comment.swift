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
    static private let audioKey = "audio"
    static private let videoKey = "video"
    
    let text: String?
    let author: Author
    let timestamp: Date
    let audio: URL?
    let video: URL?
    
    init(text: String = "", author: Author, timestamp: Date = Date(), video: URL? = nil, audio: URL? = nil) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.audio = audio
        self.video = video
    }
    
    init?(dictionary: [String : Any]) {
        guard let text = dictionary[Comment.textKey] as? String,
            let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
           
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
        
        if let audioURL = dictionary[Comment.audioKey] as? String {
            audio = URL(string: audioURL)
        } else {
            self.audio = nil
        }
        if let videoURL = dictionary[Comment.videoKey] as? String {
            video = URL(string: videoURL)
        } else {
            self.video = nil
        }
        
        self.text = text
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
       
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [Comment.textKey: text,
                Comment.author: author.dictionaryRepresentation,
                Comment.timestampKey: timestamp.timeIntervalSince1970,
                Comment.audioKey: audio?.absoluteString,
                Comment.videoKey: video?.absoluteString]
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.author == rhs.author &&
            lhs.timestamp == rhs.timestamp
    }
}
