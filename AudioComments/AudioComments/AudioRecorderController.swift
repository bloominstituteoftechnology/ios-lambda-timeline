//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by Chris Dobek on 6/2/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    // MARK: Properties
    private var timer: Timer?
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        
           let formatting = DateComponentsFormatter()
           formatting.unitsStyle = .positional // 00:00  mm:ss
           formatting.zeroFormattingBehavior = .pad
           formatting.allowedUnits = [.minute, .second]
           return formatting
       }()
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    
    
}
