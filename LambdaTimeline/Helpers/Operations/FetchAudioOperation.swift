//
//  FetchAudioOperation.swift
//  LambdaTimeline
//
//  Created by Luqmaan Khan on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchAudioOperation: ConcurrentOperation {
    
    var comment: Comment
    private var dataTask: URLSessionDataTask?
    var audioData: Data?
    
    init(comment: Comment) {
        self.comment = comment
        super.init()
    }
    
    
    override func start() {
        state = .isExecuting
        guard let url = comment.audioURL else {NSLog("audio url is nil");return}
        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            defer {self.state = .isFinished}
            if let error = error {
                NSLog("Error fetching audio url: \(error)")
                return
            }
            guard let data = data else {return}
            self.audioData = data
        })
        dataTask?.resume()
    }
    override func cancel() {
        dataTask?.cancel()
    }
    
}
