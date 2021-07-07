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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
        print((post?.comments.count ?? 0) - 1)
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        
        if comment?.audioURL != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordingCell", for: indexPath) as! RecordingTableViewCell
            
            cell.comment = comment
            loadAudio(for: cell, forItemAt: indexPath)
            cell.delegate = self
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            
            return cell
        }
    }
    
    func playAudio(for cell: RecordingTableViewCell) {
        
        if cell.isPlaying {
            cell.player?.stop()
            return
        }
        
        cell.player?.play()
    }
    
    private func updateButton(for cell: RecordingTableViewCell) {
        let playButtonTitle = cell.isPlaying ? "Stop" : "Play"
        cell.playButton.setTitle(playButtonTitle, for: .normal)
    }
    
    // MARK: -- Private Functions
    
    func loadAudio(for cell: RecordingTableViewCell, forItemAt indexPath: IndexPath) {
        guard let comment = post?.comments[indexPath.row + 1] else { return }
        
        let commentID = comment.author.uid
        
        if let audioData = audioCache.value(for: commentID) {
            let player = try! AVAudioPlayer(data: audioData)
            cell.player = player
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }
        
        let fetchOp = FetchAudioOperation(comment: comment, postController: postController)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.audioData {
                self.audioCache.cache(value: data, for: commentID)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: commentID) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: cell),
                currentIndexPath != indexPath {
                print("Got audio for now-reused cell")
                return
            }
            
            if let data = fetchOp.audioData {
                cell.player = try! AVAudioPlayer(data: data)
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
    
    private var operations = [String : Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let audioCache = Cache<String, Data>()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
