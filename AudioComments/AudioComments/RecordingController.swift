//
//  RecordingController.swift
//  AudioComments
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import Foundation

class RecordingController {

    var recordings: [Recording] = []

    func createRecording(called title: String, duration: TimeInterval, currentTime: TimeInterval, url: URL) {
        let recording = Recording(title: title, fileURL: url, duration: duration, currentTime: currentTime)
        recordings.append(recording)
    }
}
