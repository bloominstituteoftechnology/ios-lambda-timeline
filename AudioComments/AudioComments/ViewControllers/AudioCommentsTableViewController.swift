//
//  AudioCommentsTableViewController.swift
//  AudioComments
//
//  Created by Hunter Oppel on 6/2/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit

class AudioCommentsTableViewController: UIViewController {
    
    var audioComments = [URL]()
    
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    private let audioPlayerController = AudioPlayerController()
    private let audioRecorderController = AudioRecorderController()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAudioCommentSegue" {
            guard let createVC = segue.destination as? AudioCommentCreationViewController else { return }
            
            createVC.delegate = self
            createVC.audioPlayerController = audioPlayerController
            createVC.audioRecorderController = audioRecorderController
            createVC.timeIntervalFormatter = timeIntervalFormatter
        }
    }
}

extension AudioCommentsTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        audioComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentTableViewCell else {
            fatalError("Could not deque cell properly.")
        }
        
        cell.recordingURL = audioComments[indexPath.row]
        cell.timeIntervalFormatter = timeIntervalFormatter
        
        cell.elapsedTimeLabel.font = UIFont.monospacedSystemFont(ofSize: cell.elapsedTimeLabel.font.pointSize,
                                                                 weight: .regular)
        cell.timeRemainingLabel.font = UIFont.monospacedSystemFont(ofSize: cell.timeRemainingLabel.font.pointSize,
                                                                   weight: .regular)
        
        return cell
    }
}

extension AudioCommentsTableViewController: AudioCommentCreationDelegate {
    func didSaveAudioComment(_ url: URL) {
        audioComments.append(url)
        tableView.reloadData()
    }
}
