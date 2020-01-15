//
//  FetchCommentMediaOperation.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchCommentMediaOperation: ConcurrentOperation {

    private(set) var mediaURL: URL
    var postController: PostController
    var mediaData: Data?

    private let session: URLSession
    private var dataTask: URLSessionDataTask?

    init?(mediaURL: URL,
          postController: PostController,
          session: URLSession = URLSession.shared
    ) {
        self.mediaURL = mediaURL
        self.postController = postController
        self.session = session
        
        super.init()
    }

    override func start() {
        state = .isExecuting

        let task = session.dataTask(with: mediaURL) { [weak self] data, response, error in
            defer { self?.state = .isFinished }
            guard
                let self = self,
                !self.isCancelled
                else { return }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.mediaURL): \(error)")
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
