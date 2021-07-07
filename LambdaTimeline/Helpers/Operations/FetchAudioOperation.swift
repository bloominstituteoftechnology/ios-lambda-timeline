//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    init(audioURL: URL, postController: PostController, session: URLSession = URLSession.shared) {
        self.audioURL = audioURL
        self.postController = postController
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        
        let url = audioURL
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.audioURL): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }
            
            self.mediaData = data
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let audioURL: URL
    let postController: PostController
    var mediaData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
    
}
