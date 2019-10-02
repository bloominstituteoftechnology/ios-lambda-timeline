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
    
    
    private var operations = [String : Operation]()
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
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Add AudioComment", style: .default) { (_) in
            self.performSegue(withIdentifier: "AudioCommentShowSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(addAudioCommentAction)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        if let audioURL = comment?.audioURL {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentTableViewCell else { fatalError("cant make audio comment cell") }
            cell.audioURLString = audioURL
            cell.authorLabel.text = comment?.author.displayName
            loadAudio(for: cell, forItemAt: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            
            
            
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AudioCommentShowSegue" {
            guard let audioCommentVC = segue.destination as? AudioCommentViewController else { return }
            audioCommentVC.postController = postController
            audioCommentVC.post = post
        }
    }
    
    func loadAudio(for audioCell: AudioCommentTableViewCell, forItemAt indexPath: IndexPath) {
        
        let comment = post.comments[indexPath.row + 1]
        guard let audioURLString = comment.audioURL, let url = URL(string: audioURLString) else { print("return"); return}
        if let mediaData = cache.value(for: comment.author.uid+"\(comment.timestamp)") {
            audioCell.setupAudio(data: mediaData)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        let fetchOp = FetchAudioOperation(audioURL: url, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.cache.cache(value: data, for: comment.author.uid+"\(comment.timestamp)")
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: comment.author.uid+"\(comment.timestamp)") }
            
            if let currentIndexPath = self.tableView.indexPath(for: audioCell),
                currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.mediaData {
                audioCell.setupAudio(data: data)
                print("done audio fetch: \(data)")
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[comment.author.uid+"\(comment.timestamp)"] = fetchOp
    }

}
