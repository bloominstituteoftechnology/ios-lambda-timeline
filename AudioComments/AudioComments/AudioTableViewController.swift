//
//  AudioTableViewController.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit

class AudioTableViewController: UITableViewController {

    // MARK: - Properities
    let audioController = AudioController()

    // MARK: - Actions
    @IBAction func addButton(_ sender: Any) {

        let numOfRecordings = audioController.recordings.count + 1

        audioController.createRecording(title: "New Recording \(numOfRecordings)")

        updateViews()
    }

    // MARK: - Outlets

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func updateViews() {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return audioController.recordings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioTableViewCell else { return AudioTableViewCell() }

        // Configure the cell...
        cell.recording = audioController.recordings[indexPath.row]

        return cell
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
}
