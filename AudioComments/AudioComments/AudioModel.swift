//
//  AudioModel.swift
//  AudioComments
//
//  Created by Chris Dobek on 6/2/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import Foundation

struct Recording {
    var title: String = "New Recording"
    var date: Date = Date()
    var duration: Double = 0.0
    var playbackPosition: Double = 0.0
    var filename: URL?
}
