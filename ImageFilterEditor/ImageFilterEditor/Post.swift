//
//  Post.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    var title: String
    var author: String
    var longitude: Double
    var latitude: Double
    
    
    init(title: String, author: String, longitude: Double, latitude: Double) {
        self.title = title
        self.author = author
        self.longitude = longitude
        self.latitude = latitude
    }
}
