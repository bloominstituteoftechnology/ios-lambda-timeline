//
//  AudioCommentsTableViewController.swift
//  AudioComments
//
//  Created by David Wright on 5/11/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentsTableViewController: UIViewController {

    // MARK: - Properties & IBOutlets
    
    var audioComments = [AudioComment]()
    
    var audioController = AudioPlayerController() {
        didSet {
            audioController.delegate = self
        }
    }
    
    @IBOutlet var tableView: UITableView!
    
    var selectedIndexPath: IndexPath?
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Methods & IBActions
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.newAudioCommentModalSegue {
            if let nextViewController = segue.destination as? AudioRecorderController {
                nextViewController.delegate = self
            }
        }
    }
}


// MARK: - UITableViewDataSource

extension AudioCommentsTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifiers.audioCommentCell, for: indexPath) as? AudioCommentCell else { return AudioCommentCell() }
        
        cell.delegate = self
        
        let audioComment = audioComments[indexPath.row]
        cell.audioComment = audioComment
        
        if indexPath == selectedIndexPath {
            cell.audioController = audioController
        }
        
        cell.animate()
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension AudioCommentsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selectedIndexPath = selectedIndexPath, indexPath == selectedIndexPath {
            return 192
        }
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != selectedIndexPath else {
            selectedIndexPath = nil
            audioController = AudioPlayerController()
            return
        }
        
        selectedIndexPath = indexPath
        let audioURL = audioComments[indexPath.row].url
        audioController.audioURL = audioURL
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .none)
        tableView.endUpdates()
    }
}


// MARK: - AudioRecorderControllerDelegate

extension AudioCommentsTableViewController: AudioRecorderControllerDelegate {
    func didSendAudioRecording(_ audioComment: AudioComment) {
        audioComments.append(audioComment)
        tableView.reloadData()
    }
}


// MARK: - AudioCommentCellDelegate

extension AudioCommentsTableViewController: AudioCommentCellDelegate {
    func didTogglePlayback() {
        audioController.togglePlayback()
    }
    
    func didUpdateCurrentTime(time: TimeInterval) {
        audioController.updateCurrentTime(time: time)
    }
    
    func didRewind15Seconds() {
        audioController.rewindCurrentTimeBy(seconds: 15)
    }
    
    func didSkipForward15Seconds() {
        audioController.skipForwardCurrentTimeBy(seconds: 15)
    }
    
    func didDeleteAudioComment() {
        guard let index = selectedIndexPath?.row,
        let audioURL = audioComments[index].url else { return }
        
        audioController.deleteRecording(at: audioURL)
        audioController.audioURL = nil
        audioComments.remove(at: index)
    }
}


extension AudioCommentsTableViewController: AudioPlayerControllerDelegate {
    func updateAudioPlayerViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        guard let selectedIndexPath = selectedIndexPath else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [selectedIndexPath], with: .none)
        tableView.endUpdates()
    }
}
