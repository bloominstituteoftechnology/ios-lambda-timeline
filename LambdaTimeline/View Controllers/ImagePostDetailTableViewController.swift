//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Foundation

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
            
            self.postController.addComment(with: commentText, to: self.post)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Add Audio Comment", style: .default) { (_) in
            
            guard let presentedViewController = self.storyboard?.instantiateViewController(withIdentifier: "AudioCommentViewController") as? AudioCommentViewController else {fatalError("could not cast presented view controller as AudioComment View Controller")}
            
            presentedViewController.post = self.post
            presentedViewController.imagePostDVC = self
            presentedViewController.providesPresentationContextTransitionStyle = true
            presentedViewController.definesPresentationContext = true
            presentedViewController.modalPresentationStyle = .overFullScreen
            presentedViewController.view.backgroundColor = UIColor.init(white: 0.4, alpha: 0.3)
            self.present(presentedViewController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAudioCommentAction)
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { fatalError("Unable to dequeue cell as comment cell dequeue reusable cell.")}
        
        guard let comment = post?.comments[indexPath.row + 1] else { fatalError("unable to get comment for row") }
        
        cell.titleLabel.text = comment.text
        cell.subtitleLabel.text = comment.author.displayName
        
        guard comment.audioURL != nil else {
            cell.playStopButton.isEnabled = false
            cell.playStopButton.isHidden = true
            return cell
        }
        
        loadAudio(post: post, comment: comment, for: cell, forItemAt: indexPath)
        
        return cell
    }
    
    
    func loadAudio(post: Post, comment: Comment, for commentCell: CommentTableViewCell, forItemAt indexPath: IndexPath) {
        
        guard let commentID = comment.audioURL?.absoluteString else { return }
        
        let fm = FileManager.default
        let docs = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) // TODO: - change directory
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let file = docs.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        
        if let audioData = cache.value(for: commentID) {
            try? audioData.write(to: file)
            commentCell.audioURL = file
            self.tableView.reloadRows(at: [indexPath], with: .left)
            return
        }
        
        let fetchOp = FetchAudioOperation(post: post, comment: comment, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.cache.cache(value: data, for: commentID)
                DispatchQueue.main.async {
                    
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: commentID) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: commentCell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                try? data.write(to: file)
                commentCell.audioURL = file
                
                self.tableView.reloadRows(at: [indexPath], with: .right)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[commentID] = fetchOp
    }
    

    // Mark: - Properties
    var post: Post!
    var postController: PostController!
    var player: Player = Player()
    var imageData: Data?
    private let cache = Cache<String, Data>()
    private var operations = [String : Operation]()
    private let audioFetchQueue = OperationQueue()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
