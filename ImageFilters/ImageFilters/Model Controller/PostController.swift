//
//  PostsController.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/2/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import Foundation

class PostController {

    // MARK: - Properties

    var posts: [Post] = []
    var post: Post?

    // MARK: - Methods

    func createPost(title: String, url: URL) {
        let newPost = Post(title: title, recordingURL: url)
        posts.append(newPost)
        post = newPost
    }
}
