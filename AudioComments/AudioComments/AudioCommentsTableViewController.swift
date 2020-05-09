//
//  AudioCommentsTableViewController.swift
//  AudioComments
//
//  Created by Jessie Ann Griffin on 5/8/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import UIKit

class AudioCommentsTableViewController: UITableViewController {

    var listOfRecordings: [URL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRecordings?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCustomCell", for: indexPath) as? AudioCommentTableViewCell else { return UITableViewCell() }

        cell.recordingURL = listOfRecordings?[indexPath.row]

        return cell
    }

}
