//
//  RecordingController.swift
//  VideoPosts
//
//  Created by Tobi Kuyoro on 07/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation

class RecordingController {

    var recordings: [Recording] = []

    func createRecording(url: URL) {
        let recording = Recording(url: url)
        recordings.append(recording)
    }
}
