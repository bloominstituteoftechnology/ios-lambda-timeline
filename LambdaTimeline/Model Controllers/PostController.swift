//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PostController {

    static let shared = PostController()
    
    var posts: [Post] = []
    
    var currentUser: String? {
        UserDefaults.standard.string(forKey: "username")
    }
    
    func createImagePost(with title: String, image: UIImage, ratio: CGFloat?, audioURL: URL?) {
        
        guard let currentUser = currentUser else { return }
        
        let post = Post(title: title, mediaType: .image(image), ratio: ratio, author: currentUser, audioURL: audioURL)
        
        posts.append(post)
    }
    
    func addComment(with text: String, to post: inout Post) {
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(text: text, author: currentUser, audioURL: nil)
        post.comments.append(comment)

    }

    func addAudioComment(with url: URL, to post: inout Post) {
        guard let currentUser = currentUser else { return }

        let comment = Comment(author: currentUser, audioURL: url)
        post.comments.append(comment)
    }
}
