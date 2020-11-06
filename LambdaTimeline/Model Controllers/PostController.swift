//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit

class PostController {
    
    var posts: [Post] = []
    var geotagging: Bool = false
    
    var currentUser: String? {
        UserDefaults.standard.string(forKey: "username")
    }
    
    func createImagePost(with title: String, image: UIImage, ratio: CGFloat?, geotag: CLLocationCoordinate2D?) {
        
        guard let currentUser = currentUser else { return }
        
        let post = Post(title: title, mediaType: .image(image), ratio: ratio, geotag: geotag, author: currentUser)
        
        posts.append(post)
    }
    
    func createVideoPost(with title: String, videoURL: URL, geotag: CLLocationCoordinate2D?) {
        guard let currentUser = currentUser else { return }
        let post = Post(title: title, mediaType: .video(videoURL), geotag: geotag, author: currentUser)
        posts.append(post)
    }
    
    func addComment(with text: String, to post: inout Post) {
        
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(text: text, author: currentUser)
        post.comments.append(comment)

    }
    
    func addAudioComment(with url: URL, to post: inout Post) {
        guard let currentUser = currentUser else { return }
        let comment = Comment(audioURL: url, author: currentUser)
        post.comments.append(comment)
    }
    
}
