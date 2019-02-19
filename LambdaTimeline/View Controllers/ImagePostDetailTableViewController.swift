//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController, CommentPresenterViewControllerDelegate {
    
    // MARK: - Properties
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var commentType: CommentType?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    // MARK: - UI Actions
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Comment", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
        
        let textCommentAction = UIAlertAction(title: "Text", style: .default) { (_) in
            self.commentType = .text
            self.performSegue(withIdentifier: "AddCommentSegue", sender: nil)
        }
        
        let audioCommentAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            self.commentType = .audio
            self.performSegue(withIdentifier: "AddCommentSegue", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(textCommentAction)
        alert.addAction(audioCommentAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
//        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
//
//        var commentTextField: UITextField?
//
//        alert.addTextField { (textField) in
//            textField.placeholder = "Comment:"
//            commentTextField = textField
//        }
//
//        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
//
//            guard let commentText = commentTextField?.text else { return }
//
//
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        alert.addAction(addCommentAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true, completion: nil)
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
    
    // MARK: - Comments Present View Controller Delegate
    func commentPresenter(_ commentPresenter: CommentPresenterViewController, didPublishText comment: String) {
        self.postController.addComment(with: comment, to: &self.post!)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? CommentPresenterViewController {
            destinationVC.commentDelegate = self
        }
    }
    
    // MARK: - Utility Methods
    private func updateViews() {
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
}
