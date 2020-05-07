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
    // MARK: - COMMENT CONTROLS
    func saveOnAudioVC(audio: URL) {
        post.comments.append(Comment(text: nil, audio: audio, author: post.author))
        
    }
    
    @IBAction func commentButtonClicked() {
        let alert = UIAlertController(title: "Text or Audio Comment", message: "", preferredStyle: .alert)
    
        alert.addAction(UIAlertAction(title: "Text", style: .default, handler: textClicked))
        audioRecorderVC = AudioRecorderController()
        alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: { (UIAlertAction) -> Void in
            self.audioRecorderVC?.commentVC
            self.present(self.audioRecorderVC!, animated: true, completion: nil)}))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - AUDIO COMMENT
    
    func audioClicked(url: URL) {
        postController.addAudioComment(with: url, to: &post)
    }
    
    // MARK: - TEXT COMMENT
        
    func textClicked(sender : AnyObject){
        let alertController = UIAlertController(title: "Enter Comment", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Comment"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            guard let a = firstTextField.text  else {
                let alertCon = UIAlertController(title: "Enter comment to save!", message: "", preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil)
                alertCon.addAction(okAction)
                return }
            self.postController.addComment(with: a, to: &self.post)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        }


    
    
    
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var audioRecorderVC: AudioRecorderController?
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
}

