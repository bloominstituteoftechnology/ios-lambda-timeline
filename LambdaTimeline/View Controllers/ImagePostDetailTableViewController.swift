//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, AudioCommentTableViewCellDelegate, UIPopoverPresentationControllerDelegate, AVAudioPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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

    func playRecording(for cell: AudioCommentTableViewCell) {

        guard let data = cache.value(for: cell.comment!) else { return }

        do {
            player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.prepareToPlay()
            player.play()
        } catch {
            NSLog("Error playing recording: \(error)")
        }
    }
    
    @IBAction func createComment(_ sender: Any) {


        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]

        if comment?.audioURL == nil {

            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)

            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCell", for: indexPath) as? AudioCommentTableViewCell else { return AudioCommentTableViewCell() }

            cell.comment = comment
            cell.delegate = self

            loadAudio(for: cell, forItemAt: indexPath)

            return cell
        }
    }

    func loadAudio(for audioCommentCell: AudioCommentTableViewCell, forItemAt indexPath: IndexPath) {

        guard let comment = audioCommentCell.comment else { return }

        if let audioData = cache.value(for: comment) {
            audioCommentCell.audioData = audioData
            return
        }

        let fetchAudioOp = FetchAudioOperation(comment: comment, postController: postController)

        let cacheOp = BlockOperation {
            if let audioData = fetchAudioOp.audioData {
                self.cache.cache(value: audioData, for: comment)
                DispatchQueue.main.async {
                    audioCommentCell.audioData = audioData
                }
            }
        }

        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: comment) }

            if let currentIndexPath = self.tableView?.indexPath(for: audioCommentCell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }

            if let audioData = fetchAudioOp.audioData {
                audioCommentCell.audioData = audioData
            }
        }

        cacheOp.addDependency(fetchAudioOp)
        completionOp.addDependency(fetchAudioOp)

        audioFetchQueue.addOperation(fetchAudioOp)
        audioFetchQueue.addOperation(cacheOp)

        OperationQueue.main.addOperation(completionOp)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateAudioComment" {
            let destinationVC = segue.destination as! RecorderViewController

            destinationVC.post = self.post
            destinationVC.postController = self.postController
        }
    }
    
    var post: Post!
    var postController: PostController!

    private let audioFetchQueue = OperationQueue()
    private var operations = [Comment: Operation]()
    private let cache = Cache<Comment, Data>()

    var player: AVAudioPlayer!
    var imageData: Data?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
