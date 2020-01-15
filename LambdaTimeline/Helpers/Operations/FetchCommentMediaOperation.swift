//
//  FetchCommentMediaOperation.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-14.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchCommentMediaOperation: ConcurrentOperation {

    private(set) var comment: Comment
    private(set) var mediaURL: URL
    var mediaData: Data?

    private let session: URLSession
    private var dataTask: URLSessionDataTask?

    init?(comment: Comment,
         session: URLSession = URLSession.shared
    ) {
        guard case .audio(let url) = comment.content else { return nil }

        self.mediaURL = url
        self.comment = comment
        self.session = session
        
        super.init()
    }

    override func start() {
        state = .isExecuting

        let task = session.dataTask(with: mediaURL) { data, response, error in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.comment): \(error)")
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
