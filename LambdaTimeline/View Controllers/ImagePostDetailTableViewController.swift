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
    
    // MARK: - Outlets and Variables
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var player: AVPlayer?
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            self.updateViews()
        }
    }
    
    private let audioCache = Cache<String, Data>()
    private let audioFetchQueue = OperationQueue()
    
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
    
    func createTextComment() {
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: .text(commentText), to: self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Playback
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func play() {
        audioPlayer?.play()
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    
    // MARK: - Actions
    
    @IBAction func createComment(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let text = UIAlertAction(title: "Text", style: .default) { (action) in
            self.createTextComment()
        }
        
        let audio = UIAlertAction(title: "Audio", style: .default) { (action) in
            self.performSegue(withIdentifier: "AudioSegue", sender: self)
        }
        
        actionSheet.addAction(text)
        actionSheet.addAction(audio)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.titleLabel.text = comment?.text != nil && comment?.text?.isEmpty == false ? comment?.text : "Audio"
        cell.authorLabel.text = comment?.author.displayName
        cell.playButton.isHidden = comment?.text?.isEmpty == false
        cell.tag = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AudioSegue" {
            if let nc = segue.destination as? UINavigationController,
                let audioVC = nc.topViewController as? AudioCommentViewController {
                audioVC.post = self.post
                audioVC.delegate = self
            }
        }
    }
}

extension ImagePostDetailTableViewController: CommentTableViewCellDelegate {
    func didPressPlayButton(tag: Int) {
        let comment = post.comments[tag + 1]
        guard let audio = comment.audio else { return }
        print(audio)
        
        if let audioData = audioCache.value(for: String(tag)) {
            self.audioPlayer = try! AVAudioPlayer(data: audioData, fileTypeHint: "caf")
            self.audioPlayer?.play()
            return
        }
        
        let fetchOp = FetchMediaOperation(url: audio)
        
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                self.audioCache.cache(value: data, for: String(tag))
            }
        }
        
        let completionOp = BlockOperation {
            if let audioData = fetchOp.mediaData {
                self.audioPlayer = try! AVAudioPlayer(data: audioData, fileTypeHint: "caf")
                self.audioPlayer?.play()
            }
        }
        
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        
        audioFetchQueue.addOperation(fetchOp)
        audioFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)
    }
}

extension ImagePostDetailTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}

extension ImagePostDetailTableViewController: AudioCommentViewControllerDelegate {
    func didSave() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

