//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        recordButton.isEnabled = false
        recordButton.isHidden = true
        
        recorder.delegate = self
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
        
        recordButton.backgroundColor = recorder.isRecording ? UIColor.red : UIColor.white
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let optionAlert = UIAlertController(title: "Choose comment style", message: "You can write a text comment or record an audio comment.", preferredStyle: .alert)
        
        let textAction = UIAlertAction(title: "Text", style: .default, handler: { (_) in
            
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
            
            self.present(alert, animated: true, completion: nil)
        })
        
        let audioAction = UIAlertAction(title: "Audio", style: .default, handler: {(_) in
            
            let alert = UIAlertController(title: "Press Record", message: "Your recording will be added as a comment", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            // add ability to add audio
            // add ability to cancel
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: {
            self.recordButton.isEnabled = true
            self.recordButton.isHidden = false
            })
        })
        
        optionAlert.addAction(textAction)
        optionAlert.addAction(audioAction)
        
        self.present(optionAlert, animated: true, completion: nil)
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.titleLabel?.text = comment?.text
        cell.detailLabel?.text = comment?.author.displayName
        
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    private lazy var recorder = Recorder()
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: UIButton!
    @IBAction func recordButtonPressed(_ sender: Any) {
        recorder.toggleRecording()
        
    }
}


extension ImagePostDetailTableViewController: RecorderDelegate {
    func recorderDidChangeState(recorder: Recorder) {
        updateViews()
        
    }
}
