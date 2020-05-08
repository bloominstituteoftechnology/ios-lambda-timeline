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

    func createRecording(url: URL, recordingTitle: String) {
        let recording = Recording(url: url, recordingTitle: recordingTitle)
        recordings.append(recording)
    }
}
