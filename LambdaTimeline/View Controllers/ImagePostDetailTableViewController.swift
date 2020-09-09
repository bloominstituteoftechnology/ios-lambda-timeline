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
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post?.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Choose text or audio", preferredStyle: .alert)
        

        
        let addCommentAction = UIAlertAction(title: "Add Text", style: .default) { (_) in
            self.createTextComment()
        }

        let addAudioAction = UIAlertAction(title: "Add Audio", style: .default) { (_) in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "addAudioComment", sender: self)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(addAudioAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    func createTextComment() {
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)

        var commentTextField: UITextField?

        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }

        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in

            guard let commentText = commentTextField?.text else { return }

            self.postController.addTextComment(with: commentText, to: &self.post!)

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
        cell.comment = comment
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addAudioComment" {

            let destinationVC = segue.destination as? AudioViewController

            destinationVC?.postController = postController
            destinationVC?.post = post
        }
    }
}
