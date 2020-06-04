//
//  MyPostModel.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/2/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import Foundation

class Post {
    var title: String?
    var recordingURL: URL?

    init(title: String, recordingURL: URL) {
        self.title = title
        self.recordingURL = recordingURL
    }
}
