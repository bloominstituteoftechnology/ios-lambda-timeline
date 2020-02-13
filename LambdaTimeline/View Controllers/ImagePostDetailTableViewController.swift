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
        if let post = post {
            
            guard let imageData = imageData,
                let image = UIImage(data: imageData) else { return }
            
            title = post.title
            
            imageView.image = image
            
            titleLabel.text = post.title
            authorLabel.text = post.author.displayName
        } else {
            guard let image = UIImage(systemName: "video") else { return }
            imageView.image = image
            title = videoPost.title
            titleLabel.text = videoPost.title
            authorLabel.text = videoPost.author.displayName
        }
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: " Text Add Comment", style: .default) { _ in
            
            guard let commentText = commentTextField?.text else { return }
            
            if var post = self.post {
             self.postController.addComment(with: commentText, to: &post)
            } else {
             self.postController.addComment(with: commentText, to: &self.videoPost)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let audioCommentAction = UIAlertAction(title: "Add Audio Comment", style: .default) { _ in
            self.performSegue(withIdentifier: "ShowAudioCommentSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addCommentAction)
        alert.addAction(audioCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let post = post {
            return post.comments.count - 1
        } else {
            return videoPost.comments.count - 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ComentCell.reuseID, for: indexPath) as? ComentCell else { return UITableViewCell() }
        if let post = post {
            let comment = post.comments[indexPath.row + 1]
                   cell.comment = comment
                   return cell
        } else {
            let comment = videoPost.comments[indexPath.row + 1]
            cell.comment = comment
            return cell
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ShowAddAudioCommentSegue":
            guard let audioCommentVC = segue.destination as? AudioCommentViewController else { return }
            audioCommentVC.post = post
            audioCommentVC.postController = postController
            audioCommentVC.videoPost = videoPost
        default:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ComentCell else { return }
        cell.manager.togglePlayMode()
    }
    
    var post: Post!
    var videoPost: VideoPost!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
