//
//  RecordingsTableViewController.swift
//  AudioComments
//
//  Created by Tobi Kuyoro on 06/05/2020.
//  Copyright © 2020 Tobi Kuyoro. All rights reserved.
//

import UIKit

class RecordingsTableViewController: UITableViewController {

    // MARK: - Properties

    let recordingController = RecordingController()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordingController.recordings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath)

        let recording = recordingController.recordings[indexPath.row]
        cell.textLabel?.text = recording.title

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddRecording" {
            if let recordingVC = segue.destination as? RecordViewController {
                recordingVC.recordingController = recordingController
            }
        }
    }
}
