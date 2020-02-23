//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!

    // MARK: - Properties
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    private var audioOperations = [String : Operation]()
    private let audiofetchQueue = OperationQueue()
    var cache: Cache<String, Data>?
    
    struct PropertyKeys {
        static let commentCell = "CommentCell"
        static let audioCell = "AudioCell"
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
//        for comment in post.comments {
//            print(comment.text)
//        }
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Actions
    
    @IBAction func createComment(_ sender: Any) {
        
        displayCommentTypeAlert()
        
    }
    
    private func displayCommentTypeAlert() {
        let alert = UIAlertController(title: "Text or audio?", message: nil, preferredStyle: .actionSheet)
        
        let textAction = UIAlertAction(title: "Text", style: .default) { (_) in
            self.displayTextCommentAlert()
        }
        alert.addAction(textAction)
        
        let audioAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            self.displayAudioCommentAlert()
        }
        alert.addAction(audioAction)
        
        present(alert, animated: true)
    }
    
    private func displayTextCommentAlert() {
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, audioURL: nil, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func displayAudioCommentAlert() {
        self.performSegue(withIdentifier: "AudioCommentSegue", sender: self)
        print("Audio!")
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]

        if let text = comment?.text {
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.commentCell, for: indexPath)
            cell.textLabel?.text = text//comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.audioCell, for: indexPath) as? AudioCommentTableViewCell else { return UITableViewCell() }
            loadAudio(for: cell, forCellat: indexPath)
            cell.comment = comment
            
            return cell
        }
    }
    
    func loadAudio(for audioCell: AudioCommentTableViewCell, forCellat indexPath: IndexPath) {
        let comment = post.comments[indexPath.row + 1]
        
        guard let commentID = comment.audioURL?.absoluteString else { return }
        
        if let cache = cache,
            let audioData = cache.value(for: commentID) {
            print("cached")
            audioCell.data = audioData
            audioCell.loadAudio()
            return
        }
        
        let fetchOp = FetchAudioData(comment: comment)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData,
                let cache = self.cache {
                cache.cache(value: data, for: commentID)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadItems(at: [indexPath])
//                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.audioOperations.removeValue(forKey: commentID) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: audioCell),
                currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                audioCell.data = data
                audioCell.loadAudio()
                print("loaded")
//                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audiofetchQueue.addOperation(fetchOp)
        audiofetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        audioOperations[commentID] = fetchOp
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AudioCommentSegue" {
            guard let audioPostVC = segue.destination as? AudioPostViewController else { return }
            audioPostVC.postController = postController
            audioPostVC.post = post
        }
    }
}
