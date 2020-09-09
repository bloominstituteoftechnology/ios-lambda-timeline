//
//  RecordedCommentTableViewController.swift
//  audioComments
//
//  Created by Morgan Smith on 9/8/20.
//  Copyright © 2020 Morgan Smith. All rights reserved.
//

import UIKit
import AVFoundation

class RecordedCommentTableViewController: UITableViewController {

    var audioRecordings: [URL] = [] {
        didSet {
            tableView.reloadData()
            print("table view recordings: \(audioRecordings)")
        }
    }

    var audioRecording: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let audioRecording = audioRecording {
            audioRecordings.append(audioRecording)
        }
        tableView.dataSource = self
        tableView.delegate = self
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioRecordings.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "audioCommentCell", for: indexPath) as? RecordedCommentTableViewCell else { return UITableViewCell() }
        let recording = audioRecordings[indexPath.row]

        cell.recordingURL = recording
        cell.playButton.isSelected = false
        return cell
    }




    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recordingToDelete = audioRecordings[indexPath.row]
            audioRecordings.removeAll { $0 == recordingToDelete }
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        }
    }




    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
