//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    private func presentAddTextCommentDialog() {
        var commentTextField: UITextField?
        
        let textAlert = UIAlertController(title: "Add a text comment", message: "Enter your text comment", preferredStyle: .alert)
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        textAlert.addTextField { (textField) in
            textField.placeholder = "Comment"
            commentTextField = textField
        }
        
        textAlert.addAction(cancelAction)
        textAlert.addAction(addCommentAction)
        
        self.present(textAlert, animated: true, completion: nil)
    }
    private func presentRecordCommentDialog() {
        let recordAlert = UIAlertController(title: "Record a comment", message: "Click record to begin recording", preferredStyle: .alert)
        
        let addRecordedAction = UIAlertAction(title: "Record", style: .default) { (_) in
            // Begin recording
            
            let recordingAlert = UIAlertController(title: "Recording...", message: "", preferredStyle: .alert)            
            let doneRecordingAction = UIAlertAction(title: "Done Recording", style: .default) { (_) in
                // Stop recording
            }
            
            recordingAlert.addAction(doneRecordingAction)
            
            self.present(recordingAlert, animated: true, completion: nil)
        }
        
        recordAlert.addAction(cancelAction)
        recordAlert.addAction(addRecordedAction)
        self.present(recordAlert, animated: true, completion: nil)
    }
    
    @IBAction func createComment(_ sender: Any) {
        let alert = UIAlertController(title: "Add a comment", message: "Choose a comment type below", preferredStyle: .alert)
        
        let addTextCommentAction = UIAlertAction(title: "Add Text Comment", style: .default) { (_) in
            self.presentAddTextCommentDialog()
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Record Comment", style: .default) { (_) in
           self.presentRecordCommentDialog()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addTextCommentAction)
        alert.addAction(addAudioCommentAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    private let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
