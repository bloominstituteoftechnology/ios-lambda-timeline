//
//  AudioModel.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import Foundation

struct Recording {
    var title: String = "New Recording"
    var date: Date = Date()
    var duration: Double = 0.0
    var playbackPosition: Double = 0.0
    var filename: URL?
}
