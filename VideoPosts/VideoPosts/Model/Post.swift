//
//  Post.swift
//  VideoPosts
//
//  Created by David Wright on 5/14/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit

class Post: Equatable {
    
    var title: String
    var mediaURL: URL
    var ratio: CGFloat?
    let author: Author
    let timestamp: Date
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author = Author.davidWright, timestamp: Date = Date()) {
        self.title = title
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.author = author
        self.timestamp = timestamp
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.timestamp == rhs.timestamp
    }
}

struct Author: Equatable {
    let uid: String = UUID().uuidString
    let displayName: String
    
    static let davidWright = Author(displayName: "David Wright")
}
