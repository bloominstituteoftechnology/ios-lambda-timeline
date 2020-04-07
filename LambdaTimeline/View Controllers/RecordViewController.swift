//
//  RecordViewController.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    // MARK: - Variables
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    var audioPlayer: AVAudioPlayer? {
        didSet {
            // TODO: - Assign Delegate & Update Views
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
