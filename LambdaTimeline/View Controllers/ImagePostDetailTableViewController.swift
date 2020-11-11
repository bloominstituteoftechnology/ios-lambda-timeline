//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ImagePostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIBarButtonItem!
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    lazy private var player = AVPlayer()
    private var playerView: VideoPlayerView!
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
            updateViews()
        }
    }
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func updateViews() {
        if case MediaType.image(let image) = post.mediaType {
            imageView.image = image
        } else if case MediaType.video(let url) = post.mediaType {
            imageView.image = post.frameCap
            playMovie(url: url)
        }
        
        title = post?.title
        
        titleLabel.text = post.title
        authorLabel.text = post.author
    }
    
    func playMovie(url: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        
        if playerView == nil {
            playerView = VideoPlayerView()
            playerView.player = player
            
            var topRect = view.bounds
            topRect.size.width /= 4
            topRect.size.height /= 4
            topRect.origin.y = view.layoutMargins.top
            topRect.origin.x = view.bounds.size.width - topRect.size.width
            
            playerView.frame = topRect
            view.addSubview(playerView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playRecording(_:)))
            playerView.addGestureRecognizer(tapGesture)
        }
        
        player.play()
    }
    
    @IBAction func playRecording(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        
        self.present(playerVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "New Comment", message: "Which kind of comment do you want to create?", preferredStyle: .actionSheet)
        
        let textCommentAction = UIAlertAction(title: "Text", style: .default) { (_) in
            self.createTextComment()
        }
        
        let audioCommentAction = UIAlertAction(title: "Audio", style: .default) { (_) in
            self.createAudioComment()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(textCommentAction)
        alert.addAction(audioCommentAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createAudioComment() {
        performSegue(withIdentifier: "AddAudioComment", sender: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        if comment?.audioURL == nil {
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author
        } else if comment?.text == nil {
            cell.textLabel?.text = "\(comment!.author)'s Audio Comment"
            cell.detailTextLabel?.text = "Tap to play"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = post?.comments[indexPath.row + 1]
        
        if comment?.audioURL == nil {
            
        } else if comment?.text == nil {
            audioPlayer = try? AVAudioPlayer(contentsOf: (comment?.audioURL)!)
            togglePlayback()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAudioComment" {
            if let audioVC = segue.destination as? AudioRecorderController {
                audioVC.postController = postController
                audioVC.post = post
            }
        }
    }
    
    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
        } catch {
            print("Cannot play audio: \(error)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: [])
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
