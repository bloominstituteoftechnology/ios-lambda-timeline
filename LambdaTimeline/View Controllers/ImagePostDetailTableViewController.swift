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
        
        let alert = UIAlertController(title: "Add a comment", message: "Choose which type of comment you would like to add:", preferredStyle: .actionSheet)
        
        let addCommentAction = UIAlertAction(title: "Add Text Comment", style: .default) { (_) in
            let textCommentAlert = UIAlertController(title: "Add a text comment", message: "Write your comment below:", preferredStyle: .alert)
            
            var commentTextField: UITextField?
            
            textCommentAlert.addTextField { (textField) in
                textField.placeholder = "Comment:"
                commentTextField = textField
            }
            
            let addTextCommentAction = UIAlertAction(title: "Add Text Comment", style: .default) { (_) in
                guard let commentText = commentTextField?.text else { return }
                self.postController.addComment(with: commentText, to: &self.post!)

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        
            let cancelTextCommentAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            textCommentAlert.addAction(addTextCommentAction)
            textCommentAlert.addAction(cancelTextCommentAction)
            self.present(textCommentAlert, animated: true)
        }
        
        let addAudioAction = UIAlertAction(title: "Add Audio Comment", style: .default) { (_) in
            /*
            ADD SUPPORT FOR RECORDING AUDIO
            */
            self.performSegue(withIdentifier: "RecordAudioModalSegue", sender: self)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(addAudioAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]
        
        
        if comment?.audioURL != nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentTableViewCell else {
                return UITableViewCell()
            }
            
            cell.delegate = self
            cell.comment = comment

            return cell
        } else if comment?.text != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        }
        return UITableViewCell()
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordAudioModalSegue" {
            guard let RecordAudioCommentVC = segue.destination as? RecordAudioCommentViewController else { return }
            RecordAudioCommentVC.delegate = self
        }
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Timer
    var timer: Timer?
    
    func startTimer() {
        timer?.invalidate() // Cancel a timeer before you start a new one
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updatePlayer()

        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Playback
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            // Using a didSet allows us to make sure we don't forget to set the delegate
            audioPlayer?.delegate = self
            audioPlayer?.isMeteringEnabled = true
        }
    }
    
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    func loadAudio(audioURL: URL) {
        audioPlayer = try? AVAudioPlayer(contentsOf: audioURL)
        print("loaded")
    }
    
    
    // Fixes bug for iPhone
    func prepareAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // can fail if on a phone call, for instance
    }
    
    
    func play() {
        audioPlayer?.play()
        startTimer()
        updatePlayer()
    }
    
    func pause() {
        audioPlayer?.pause()
        cancelTimer()
        updatePlayer()
    }
    
    
    
    private func updatePlayer() {
    }
    
    
}

extension ImagePostDetailTableViewController: AudioURLDelegate {
    func passAudioURL(for url: URL) {
        self.postController.addAudioComment(with: url, to: &self.post!)
        tableView.reloadData()
    }
}

extension ImagePostDetailTableViewController: PlayCommentAudioDelegate {
    func playAudio(for url: URL) {
        loadAudio(audioURL: url)
        
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}

extension ImagePostDetailTableViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        updatePlayer()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("⚠️ Audio Player Error: \(error)")
        }
        updatePlayer()
    }
}
