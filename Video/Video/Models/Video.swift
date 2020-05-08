//
//  Video.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import Foundation

class Video: NSObject {
    init(recordingURL: URL, name: String, latitude: Double, longitude: Double, author: String) {
        self.recordingURL = recordingURL
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.author = author
    }
    
    let recordingURL: URL
    let name: String
    let author: String
    let latitude: Double
    let longitude: Double
}
