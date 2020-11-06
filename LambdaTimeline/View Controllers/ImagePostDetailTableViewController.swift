//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVKit

class ImagePostDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIBarButtonItem!
    
    var post: Post!
    var postController: PostController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        switch post.mediaType {
        case .image(let image):
            imageView.image = image
        case .video(let videoURL):
            imageFromVideo(url: videoURL, at: 0) { image in
                self.imageView.image = image
            }
        }
        title = post?.title
        titleLabel.text = post.title
        authorLabel.text = post.author
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below or choose Audio Comment", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Text Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let addAudioCommentAction = UIAlertAction(title: "Add Audio Comment", style: .default) { (_) in
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let audioVC = storyBoard.instantiateViewController(withIdentifier: "AudioRecorderController") as! AudioRecorderController
            audioVC.delegate = self
            self.present(audioVC, animated: true, completion: nil)
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
        let comment = post?.comments[indexPath.row + 1]
        if comment?.audioURL == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath)
            cell.textLabel?.text = comment?.author
            return cell
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playCommentSegue" {
            if let audioVC = segue.destination as? AudioRecorderController,
               let indexPath = tableView.indexPathForSelectedRow {
                let comment = post.comments[indexPath.row + 1]
                audioVC.playOnlyMode = true
                audioVC.recordingURL = comment.audioURL
            }
        }
    }
    
    private func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)

            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
}

extension ImagePostDetailTableViewController: AudioRecorderDelegate {
    func updatePostWithAudioComment(url: URL) {
        postController.addAudioComment(with: url, to: &post)
        tableView.reloadData()
    }
}
