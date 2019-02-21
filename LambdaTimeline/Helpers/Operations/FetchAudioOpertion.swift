//
//  FetchAudioOpertion.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    init(post: Post, comment: Comment, postController: PostController, session: URLSession = URLSession.shared) {
        self.post = post
        self.postController = postController
        self.session = session
        self.comment = comment
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        guard let audioURL = comment.audioURL else { return }
        let task = session.dataTask(with: audioURL) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.post): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }
            
            self.audioData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let post: Post
    let comment: Comment
    let postController: PostController
    var audioData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
}
