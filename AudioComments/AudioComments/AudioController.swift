//
//  AudioController.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
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

        // FIXME: Delete URL off disk
    }
}
