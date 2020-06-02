//
//  AudioController.swift
//  AudioComments
//
//  Created by Chris Dobek on 6/2/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation

class AudioController {

    private(set) var recordings = [Recording]()

    // MARK: - CRUD

    // Create

    func createRecording(title: String) {
        let newRecording = Recording(title: title, date: Date())
        recordings.append(newRecording)
    }

    // Read

    // Update

    // Delete
    func deleteRecording(index: Int) {
        recordings.remove(at: index)

        // TODO: Delete URL off disk
    }
}
