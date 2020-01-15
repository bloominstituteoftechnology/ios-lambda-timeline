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

    private var operations = [String: Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()

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
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(withText: commentText, to: &self.post)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]
        if let commentText = comment?.text {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TextCommentCell",
                for: indexPath)
            cell.textLabel?.text = commentText
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        } else if let commentAudioURL = comment?.audioURL,
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AudioCommentCell",
                for: indexPath)
                as? AudioCommentTableViewCell {
            cell.authorLabel.text = comment?.author.displayName
            cell.audioPlayerControl.loadAudio(from: commentAudioURL)
            return cell
        } else { return UITableViewCell() }
    }

    // MARK: - Fetching

    func loadAudioData(
        forComment comment: Comment,
        withCell audioCommentCell: AudioCommentTableViewCell,
        at indexPath: IndexPath
    ) {
        
    }
}
