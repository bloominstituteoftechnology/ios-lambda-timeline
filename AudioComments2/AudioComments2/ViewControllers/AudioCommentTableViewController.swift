//
//  AudioCommentTableViewController.swift
//  AudioComments
//
//  Created by Chris Gonzales on 4/7/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import UIKit

class AudioCommentTableViewController: UITableViewController {

    let audioCommentController = AudioCommentController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAudioCommentSegue" {
            guard let destinationVC = segue.destination as? AudioCommentViewController else { return }
            destinationVC.audioCommentController = audioCommentController
        }
    }
    

}
