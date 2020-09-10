//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIBarButtonItem!

    
    var post: Post!
    let postController = PostController.shared
    var imageData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        guard case MediaType.image(let image) = post.mediaType else { return }
        
        title = post?.title
        
        imageView.image = image
        titleLabel.text = post.title
        authorLabel.text = post.author
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {

        let alert = UIAlertController(title: "New Comment", message: "What kind of comment do you want to create?", preferredStyle: .actionSheet)
        
        let textCommentAction = UIAlertAction(title: "Text", style: .default, handler: { (_) in
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
            self.present(alert, animated: true, completion: nil)
        })

        let audioCommentAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "AudioCommentViewController") as! AudioCommentViewController
            vc.post = self.post
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(textCommentAction)
        alert.addAction(audioCommentAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]

        if comment?.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioCommentTableViewCell else { return UITableViewCell() }

            let comment = post?.comments[indexPath.row + 1]
            cell.recordingURL = comment?.audioURL
            cell.usernameLabel.text = comment?.author

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)

            let comment = post?.comments[indexPath.row + 1]
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author

            return cell
        }
    }
}

extension ImagePostDetailTableViewController: VoiceCommentAddedDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}
