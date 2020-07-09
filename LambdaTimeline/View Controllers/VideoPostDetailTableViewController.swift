//
//  VideoPostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class VideoPostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var playerView: PlaybackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    var post: Post!
    var postController: PostController!
    var geotag: CLLocationCoordinate2D?
    var videoURL: URL?
    var player: AVPlayer!
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
        if let videoURL = self.videoURL {
            player = AVPlayer(url: videoURL)
            playerView.playerLayer.player = player
            player.play()
            loopVideo(videoPlayer: player)
        }
        
        title = post?.title
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
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
    
    func loopVideo(videoPlayer: AVPlayer) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            videoPlayer.seek(to: CMTime.zero)
            videoPlayer.play()
        }
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

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (post?.comments.count ?? 0) - 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentVideoCell", for: indexPath) as? CommentVideoTableViewCell else { return UITableViewCell() }

        let comment = post?.comments[indexPath.row + 1]
        
        cell.titleLabel.text = comment?.text != nil && comment?.text?.isEmpty == false ? comment?.text : "Audio"
        cell.authorLabel.text = comment?.author.displayName
        cell.playButton.isHidden = comment?.text?.isEmpty == false
        cell.tag = indexPath.row
        cell.delegate = self

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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

extension VideoPostDetailTableViewController: CommentVideoTableViewCellDelegate {
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

extension VideoPostDetailTableViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updateViews()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Audio Player Error: \(error)")
        }
    }
}

extension VideoPostDetailTableViewController: AudioCommentViewControllerDelegate {
    func didSave() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
