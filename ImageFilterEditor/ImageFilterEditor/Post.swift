//
//  Post.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation

class Post: NSObject {
    
    var imageTitle: String?
    var author: String?
    var longitude: Double?
    var latitude: Double?
    
    
    init(imageTitle: String, author: String, longitude: Double, latitude: Double) {
        self.imageTitle = imageTitle
        self.author = author
        self.longitude = longitude
        self.latitude = latitude
    }
}
