//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    //MARK: - Properties
    
    var recordingURL: URL?
    var name: String?
    
    //MARK: - Views
    
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
        
        // Text Comment Alert
        
        let textCommentAlert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        textCommentAlert.addTextField { (textField) in
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
        
        textCommentAlert.addAction(addCommentAction)
        textCommentAlert.addAction(cancelAction)
        
        
        // Comment Alert
        
        let commentAlert = UIAlertController(title: "Would you like to write or record a comment?", message: "", preferredStyle: .alert)
        
        commentAlert.addAction(UIAlertAction(title: "Write", style: .default, handler: { (_) in
            self.present(textCommentAlert, animated: true, completion: nil)
        }))
        
        commentAlert.addAction(UIAlertAction(title: "Record", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "recordSegue", sender: self)
        }))
        
        present(commentAlert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        let comment = post?.comments[indexPath.row + 1]
        if name != nil {
            cell.nameLabel.text = name
        } else {
            cell.nameLabel.text = comment?.text
        }
        cell.recordingURL = recordingURL
        
        
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
