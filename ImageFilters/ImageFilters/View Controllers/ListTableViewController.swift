//
//  ListTableViewController.swift
//  ImageFilters
//
//  Created by Mark Poggi on 6/2/20.
//  Copyright © 2020 Mark Poggi. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    // MARK: - Properties

    var postController = PostController()

    // MARK: View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(postController.posts.count)
        return postController.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
        let results = postController.posts[indexPath.row]
        cell.textLabel?.text = results.title
        print(cell)
        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

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

    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newAudioRecordingSegue" {
            guard let destinationVC = segue.destination as? AudioRecorderController else { return }
            destinationVC.postController = postController
        } else if segue.identifier == "viewAudioRecordingSegue" {
            guard let destinationVC = segue.destination as? AudioRecorderController,
                let indexPath = tableView.indexPathForSelectedRow else { return }
            let posts = postController.posts[indexPath.row]
            destinationVC.postController = postController
            return
        }
    }
}
