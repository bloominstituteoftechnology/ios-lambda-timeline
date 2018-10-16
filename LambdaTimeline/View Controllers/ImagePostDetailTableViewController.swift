//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

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
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        let alert = UIAlertController(title: "Add a comment", message: "Choose a comment type below", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let addTextCommentAction = UIAlertAction(title: "Add Text Comment", style: .default) { (_) in
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
        
        let addAudioCommentAction = UIAlertAction(title: "Record Comment", style: .default) { (_) in
            let recordAlert = UIAlertController(title: "Record a comment", message: "Click record to begin recording", preferredStyle: .alert)
            let addRecordedAction = UIAlertAction(title: "Record", style: .default) { (_) in
                
                let recordingAlert = UIAlertController(title: "Recording...", message: "", preferredStyle: .alert)
                
                // Begin recording                
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
        
        alert.addAction(cancelAction)
        alert.addAction(addTextCommentAction)
        alert.addAction(addAudioCommentAction)
        
        present(alert, animated: true, completion: nil)
    }
    
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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
