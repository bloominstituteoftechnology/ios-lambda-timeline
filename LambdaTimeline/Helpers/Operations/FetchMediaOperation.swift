//
//  FetchMediaOperation.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class FetchMediaOperation: ConcurrentOperation {
    
    // MARK: Properties
    var mediaData: Data?
    
    private let mediaURL: URL

    private let session: URLSession
    
    private var dataTask: URLSessionDataTask?

    // changed this from using post to just using the url
    init(url: URL, session: URLSession = URLSession.shared) {
        self.mediaURL = url
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
    
        let task = session.dataTask(with: self.mediaURL) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data: \(error)")
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
}
