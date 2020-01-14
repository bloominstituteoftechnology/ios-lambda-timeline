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
    
    func loadAudio(for imagePostCell: RecordingTableViewCell, forItemAt indexPath: IndexPath) {
//        let post = postController.posts[indexPath.row]
//
//        guard let postID = post.id else { return }
//
//        if let mediaData = cache.value(for: postID),
//            let image = UIImage(data: mediaData) {
//            imagePostCell.setImage(image)
//            self.collectionView.reloadItems(at: [indexPath])
//            return
//        }
//
//        let fetchOp = FetchAudioOperation(post: post, postController: postController)
//
//        let cacheOp = BlockOperation {
//            if let data = fetchOp.mediaData {
//                self.cache.cache(value: data, for: postID)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadItems(at: [indexPath])
//                }
//            }
//        }
//
//        let completionOp = BlockOperation {
//            defer { self.operations.removeValue(forKey: postID) }
//
//            if let currentIndexPath = self.collectionView?.indexPath(for: imagePostCell),
//                currentIndexPath != indexPath {
//                print("Got image for now-reused cell")
//                return
//            }
//
//            if let data = fetchOp.mediaData {
//                imagePostCell.setImage(UIImage(data: data))
//                self.collectionView.reloadItems(at: [indexPath])
//            }
//        }
        
//        cacheOp.addDependency(fetchOp)
//        completionOp.addDependency(fetchOp)
//
//        mediaFetchQueue.addOperation(fetchOp)
//        mediaFetchQueue.addOperation(cacheOp)
//        OperationQueue.main.addOperation(completionOp)
//
//        operations[postID] = fetchOp
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
        
        let addRecordingAction = UIAlertAction(title: "Add Recording", style: .default) { (_) in
            self.performSegue(withIdentifier: "AddRecordingSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        alert.addAction(addRecordingAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        
        if comment?.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as? RecordingTableViewCell else { return UITableViewCell() }
            
            cell.recordingNameLabel.text = comment?.author.displayName
            cell.comment = comment
            loadAudio(for: cell, forItemAt: indexPath)
            
            return cell
            
        } else if comment?.text != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
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
}
