//
//  AudioCommentsTableViewController.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/10/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentsTableViewController: UITableViewController {
 
    var audioComments = [URL]()
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
           // NOTE: DateComponentFormatter is good for minutes/hours/seconds
           // DateComponentsFormatter is not good for milliseconds, use DateFormatter instead)
           
           let formatting = DateComponentsFormatter()
           formatting.unitsStyle = .positional // 00:00  mm:ss
           formatting.zeroFormattingBehavior = .pad
           formatting.allowedUnits = [.minute, .second]
           return formatting
       }()
    
    let audioPlayerController = AudioPlayerController()
    let audioRecordingController = AudioRecorderController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioComments.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCell", for: indexPath) as? AudioCommentTableViewCell else {
            fatalError("Could not deque cell properly")
        }
        cell.recordingURL = audioComments[indexPath.row]
        cell.timeIntervalFormatter = timeIntervalFormatter
        cell.elapsedTimeLabel.font = UIFont.monospacedSystemFont(ofSize: cell.elapsedTimeLabel.font.pointSize,
                                                                 weight: .regular)
        cell.durationLabel.font = UIFont.monospacedSystemFont(ofSize: cell.durationLabel.font.pointSize,
                                                              weight: .regular)
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createAudioSegue" {
            guard let createVC = segue.destination as? CreateAudioCommentViewController else { return }
    
            createVC.audioRecorderController = audioRecordingController
            createVC.audioPlayerController = audioPlayerController
            createVC.timeIntervalFormatter = timeIntervalFormatter
            createVC.delegate = self
        }
    }


}

extension AudioCommentsTableViewController: CreateCommentDelegate {
    func didSaveAudioComment(_ url: URL) {
        audioComments.append(url)
        tableView.reloadData()
    }
}
