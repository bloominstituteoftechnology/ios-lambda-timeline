//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController, AudioCommentsUpdateDelegate {

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
    
    func audioCommentsDidUpdate() {
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Comment", message: "Which kind of comment do you want to post?", preferredStyle: .actionSheet)
        
        let textCommentAction = UIAlertAction(title: "Text", style: .default) { (_) in
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
            
            self.present(alert, animated: true, completion: nil)
        }
        
        let audioCommentAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            
            self.performSegue(withIdentifier: "AddAudioComment", sender: nil)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell()}
        
        let comment = post?.comments[indexPath.row + 1]
        cell.comment = comment
        
        if comment?.audioURL != nil {
            loadAudio(for: cell, forItemAt: indexPath)
        }
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAudioComment" {
            guard let destinationVC = segue.destination as? RecordAudioCommentViewController else { return }
            
            destinationVC.post = post
            destinationVC.postController = postController
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Private Method
    
    private func loadAudio(for cell: CommentTableViewCell, forItemAt indexPath: IndexPath) {
        
        let comment = post.comments[indexPath.row + 1]
        let commentTimestamp = comment.timestamp
        
        if let audioData = cache.value(for: commentTimestamp) {
            cell.audioData = audioData
            self.tableView.reloadRows(at: [indexPath], with: .right)
        }
        
        let fetchOp = AudioFetchOperation(comment: comment)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.cache.cache(value: data, for: commentTimestamp)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .right)
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: commentTimestamp)}
            
            if let currentIndexPath = self.tableView.indexPath(for: cell), currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                cell.audioData = data
                self.tableView.reloadRows(at: [indexPath], with: .right)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[commentTimestamp] = fetchOp
    }
    
    // MARK: - Properties
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    private let cache = Cache<Date, Data>()
    private var operations = [Date : Operation]()
    private let audioFetchQueue = OperationQueue()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
