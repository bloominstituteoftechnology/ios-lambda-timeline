//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, RecordingTableViewCellDelegate {
    
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
        
        let addRecordingAction = UIAlertAction(title: "Add Recording", style: .default) { (_) in
            
            self.performSegue(withIdentifier: "CreateAudio", sender: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addRecordingAction)
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let recordingCell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingTableViewCell
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        recordingCell.comment = comment
        loadAudio(for: recordingCell, forItemAt: indexPath)
        recordingCell.delegate = self
        
        return comment?.audioURL == nil ? cell : recordingCell
    }
    
    func playAudio(for cell: RecordingTableViewCell) {
        
        if cell.isPlaying {
            cell.player?.stop()
            return
        }
        
        cell.player?.play()
    }
    
    // MARK: -- Private Functions
    
    func loadAudio(for audioCommentCell: RecordingTableViewCell, forItemAt indexPath: IndexPath) {
        guard let comment = post?.comments[indexPath.row + 1] else { return }
        
        let commentID = comment.timestamp
        
        if let audioData = cache.value(for: commentID) {
            let player = try! AVAudioPlayer(data: audioData)
            audioCommentCell.player = player
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        let fetchOp = FetchAudioOperation(comment: comment, postController: postController)
        
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
            
            if let currentIndexPath = self.tableView?.indexPath(for: audioCommentCell),
                currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                audioCommentCell.player = try! AVAudioPlayer(data: data)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
        
        operations[commentID] = fetchOp
    }
    
    // MARK: -- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateAudio" {
            guard let destination = segue.destination as? RecordAudioViewController else { return }
            
            destination.post = post
            destination.postController = postController
        }
    }
    
    // MARK: -- Properties
    
    var post: Post! 
    var postController: PostController!
    var imageData: Data?
    
    private var operations = [Date : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<Date, Data>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
