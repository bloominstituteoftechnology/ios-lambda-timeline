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
        self.recordPopOver.layer.cornerRadius = 10

        let session = AVAudioSession.sharedInstance()
        
        session.requestRecordPermission { (granted) in
            guard granted else {
                NSLog("Permisson Faild")
                return
            }
            do {
                try session.setCategory(.playAndRecord, mode: .default, options: [])
                try session.setActive(true, options: [])
            } catch {
                NSLog("Error setting AVAudioSession: \(error)")
            }
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
        
        let addAudioCommentAction = UIAlertAction(title: "Add Audio", style: .default) { (_) in

            alert.dismiss(animated: true, completion: nil)
            self.view.addSubview(self.recordPopOver)
            self.recordPopOver.center = self.view.center
           self.present(alert, animated: true, completion: nil)
        
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(addAudioCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    private var player: AVAudioPlayer?
    private var recorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
        
    @IBOutlet var recordPopOver: UIView!
    @IBOutlet weak var recordButton: UIButton!
}


extension ImagePostDetailTableViewController: AVAudioRecorderDelegate {

    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }

    @IBAction func recordButton(_ sender: Any) {
        
        defer { updateButtons() }
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
            recorder = try AVAudioRecorder(url: newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Recording Failed: \(error)")
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        recordingURL = recorder.url
        recordPopOver.removeFromSuperview()
    }
    
    func updateButtons() {
        let recordButtonTitle = isRecording ? "Stop Recording" : "Tap to Record"
        recordButton.setTitle(recordButtonTitle, for: .normal)
    }
    
    private func newRecordingURL() -> URL {
        do {
            let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            return documentsDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("caf")
        }
        
    }
    
    
    
}
