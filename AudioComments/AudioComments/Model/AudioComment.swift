//
//  AudioComment.swift
//  AudioComments
//
//  Created by David Wright on 5/11/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import Foundation

struct AudioComment {
    
    init(title: String, duration: TimeInterval, url: URL? = nil) {
        self.title = title
        self.duration = duration
        self.url = url
    }
    
    var title: String
    let duration: TimeInterval
    let url: URL?
    let timeStamp: Date = Date()
}
