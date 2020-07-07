//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {

    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
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
        let alert = UIAlertController(title: "Add A Comment", message: "Select a comment type below:", preferredStyle: .alert)
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addTextCommentAction = UIAlertAction(title: "Add a Text Comment", style: .default) { (_) in
            guard let commentText = commentTextField?.text else { return }
            self.postController.addComment(with: commentText, to: &self.post!)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Leave an Audio Comment Instead", style: .default, handler: { _ in
            self.performSegue(withIdentifier: "AudioCommentModalSegue", sender: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addTextCommentAction)
        alert.addAction(addAudioCommentAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        
//        switch comment?.type {
//        case .text:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
//            cell.textLabel?.text = comment?.text
//            cell.detailTextLabel?.text = comment?.author.displayName
//            return cell
//        case .audio:
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentTableViewCell else { return UITableViewCell() }
//            cell.authorLabel.text = comment?.author.displayName
//        default:
//            return UITableViewCell()
//        }
        
        if comment?.type == .text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        } else if comment?.type == .audio {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentTableViewCell else { return UITableViewCell() }
            cell.authorLabel.text = comment?.author.displayName
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AudioCommentModalSegue" {
            _ = segue.destination as? AudioCommentViewController
        }
    }
}
