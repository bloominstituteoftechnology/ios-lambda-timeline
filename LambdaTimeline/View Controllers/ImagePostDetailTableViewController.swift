//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        let alert = UIAlertController(title: "Add a comment", message: nil, preferredStyle: .actionSheet)
        
        let textAction = UIAlertAction(title: "Text", style: .default) { _ in
            DispatchQueue.main.async {
                self.showTextCommentAlert()
            }
        }
        
        let audioAction = UIAlertAction(title: "Audio", style: .default) { _ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "OpenRecorder", sender: self)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(textAction)
        alert.addAction(audioAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showTextCommentAlert() {
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
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]
        
        let isTextComment: Bool = comment?.text != nil
        
        let cellIdentifier: String
        if isTextComment {
            cellIdentifier = "CommentCell"
        } else {
            cellIdentifier = "AudioCommentCell"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if isTextComment {
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
        } else {
            cell.textLabel?.text = comment?.author.displayName
            cell.detailTextLabel?.text = "▶️"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let comment = post?.comments[indexPath.row + 1],
            let audioURL = comment.audioURL,
            let cell = tableView.cellForRow(at: indexPath) {
            
            audioPlayer?.stop()
            resetPlayingCell()
            
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.play()
                audioPlayer.delegate = self
                
                self.audioPlayer = audioPlayer
                audioPlayerIndexPath = indexPath
                
                cell.detailTextLabel?.text = "⏸"
            } catch {
                NSLog("Error getting audio player: \(error)")
            }
        }
    }
    
    //MARK: Private
    
    private func resetPlayingCell() {
        if let indexPath = audioPlayerIndexPath,
            let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = "▶️"
        }
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenRecorder",
            let navController = segue.destination as? UINavigationController,
            let audioRecorderVC = navController.viewControllers.first as? AudioRecorderViewController {
            audioRecorderVC.delegate = self
        }
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    var audioPlayer: AVAudioPlayer?
    var audioPlayerIndexPath: IndexPath?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}

extension ImagePostDetailTableViewController: AudioRecorderDelegate {
    func saveRecording(_ recordURL: URL) {
        postController.addComment(with: recordURL, to: &post)
        tableView.reloadData()
    }
}

extension ImagePostDetailTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            NSLog("Record error: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        resetPlayingCell()
    }
}
