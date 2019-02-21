//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, PlayerDelegate, RecorderDelegate {
  
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    func playerDidChangeState(_ playe: Player) {
        updateViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        player.delegate = self
        recorder.delegate = self
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
    var cameraBool: Bool = false
    var recordFile: URL?
    private let player = Player()
    private let recorder = Recorder()
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Leave Comment", message: "Please Select an Option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Text Comment", style: .default, handler: { (_) in
            print("User click Text Comment button")
            let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
            var commentTextField: UITextField?
            
            alert.addTextField { (textField) in
                textField.placeholder = "Comment:"
                commentTextField = textField
            }
            
            let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
                
                guard let commentText = commentTextField?.text else { return }
                
                self.postController.addComment(with: commentText, to: self.post!)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(addCommentAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Audio Comment", style: .default, handler: { (_) in
            print("User click Audio Comment button")

                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "audio") as! ViewController
                self.present(nextViewController, animated:true, completion:nil)
         
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
         
            
            self.present(alert, animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Video Comment", style: .default, handler: { (_) in
            print("User click Video Comment button")
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Video") as! CameraViewController
            self.present(nextViewController, animated:true, completion:nil)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            
            self.present(alert, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! ImagePostTableViewCell
        
        let comment = post?.comments[indexPath.row + 1]
        
        cell.comment?.text = comment?.text
        cell.author?.text = comment?.author.displayName
        //cell.play.titleLabel?.text = comment?.audio!.absoluteString
        cell.playAction(player.play(song: recordFile))
        return cell
    }
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
