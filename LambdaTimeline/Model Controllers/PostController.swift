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
    
    var currentUser: String? {
        UserDefaults.standard.string(forKey: "username")
    }
    
    func createImagePost(with title: String, image: UIImage, ratio: CGFloat?, geotag: CLLocationCoordinate2D? = nil) {
        guard let currentUser = currentUser else { return }
        
        let post = Post(title: title, mediaType: .image(image), ratio: ratio, author: currentUser, geotag: geotag)
        
        posts.append(post)
    }
    
    func createVideoPost(with title: String, image: UIImage, video: URL, ratio: CGFloat?, geotag: CLLocationCoordinate2D? = nil) {
        guard let currentUser = currentUser else { return }
        
        let post = Post(title: title, mediaType: .video(video), frameCap: image, ratio: ratio, author: currentUser, geotag: geotag)
        
        posts.append(post)
    }
    
    func addComment(with text: String, to post: inout Post) {
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(text: text, author: currentUser)
        post.comments.append(comment)
    }
    
    func addComment(with audio: URL, to post: inout Post) {
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(author: currentUser, audioURL: audio)
        post.comments.append(comment)
    }
}
