//
//  AudioCommentsTableViewController.swift
//  AudioComments
//
//  Created by Hunter Oppel on 6/2/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit

class AudioCommentsTableViewController: UIViewController {
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    private let audioPlayerController = AudioPlayerController()
    private let audioRecorderController = AudioRecorderController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAudioCommentSegue" {
            guard let createVC = segue.destination as? AudioCommentCreationViewController else { return }
            
            createVC.audioPlayerController = audioPlayerController
            createVC.audioRecorderController = audioRecorderController
            createVC.timeIntervalFormatter = timeIntervalFormatter
        }
    }
}

