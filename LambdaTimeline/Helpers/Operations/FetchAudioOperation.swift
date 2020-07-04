//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Daniela Parra on 11/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class AudioFetchOperation: ConcurrentOperation {
    
    init(comment: Comment, session: URLSession = URLSession.shared) {
        self.comment = comment
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        
        guard let url = comment.audioURL else { return }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching audio for \(self.comment): \(error)")
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
    
    let comment: Comment
    var audioData: Data?
    
    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?
}
