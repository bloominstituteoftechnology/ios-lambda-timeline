//
//  Recording.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 07/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation

class Recording: NSObject {
    var url: URL
    var recordingTitle: String

    init(url: URL, recordingTitle: String) {
        self.url = url
        self.recordingTitle = recordingTitle
    }
}
