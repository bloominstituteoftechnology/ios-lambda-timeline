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
        typeOfCommentAlert()
    }
    
    private func typeOfCommentAlert() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let textCommentAction = UIAlertAction(title: "Text Comment", style: .default) { action in
            self.textComment()
        }
        
        let audioCommentAction = UIAlertAction(title: "Audio Comment", style: .default) { action in
            self.performSegue(withIdentifier: "ShowAudioCommentView", sender: nil)
        }
        
        let videoCommentAction = UIAlertAction(title: "Video Comment", style: .default) { action in
            self.performSegue(withIdentifier: "ShowVideoComment", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(textCommentAction)
        alert.addAction(audioCommentAction)
        alert.addAction(videoCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func textComment() {
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?

        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
        
            guard let commentText = commentTextField?.text else { return }
        
            self.postController.addComment(with: commentText, to: &self.post!)
        
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        guard let comment = post?.comments[indexPath.row + 1] else { return UITableViewCell() }
        
//        cell.textLabel?.text = comment?.text
//        cell.detailTextLabel?.text = comment?.author.displayName

        if comment.isTextComment {
            cell.titleLabel.text = comment.text
            cell.subtitleLabel.text = comment.author.displayName
            cell.playButton.isHidden = true
        } else {
            cell.titleLabel.text = comment.author.displayName
            cell.subtitleLabel.text = ""
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowVideoComment" {
            
        }
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
