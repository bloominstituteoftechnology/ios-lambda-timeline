//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
    
    //MARK:- Properties
    
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    //MARK:- View Life Cycle
    
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
    
    private let audioController: UINavigationController = {
           let audioRecordingViewController = AudioRecordingViewController()
       let vc = UINavigationController(rootViewController: audioRecordingViewController)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    // MARK: - Table view data source
    private func showCommentActionSheet() {
        let ac = UIAlertController(title: "Add comment to picture", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Add text comment", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.handleTextComment()
        }))
        ac.addAction(UIAlertAction(title: "Add audio comment", style: .default, handler: { [weak self] (action) in
            guard let self = self else { return }
            self.present(self.audioController, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    private func handleTextComment() {
                let ac = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
                var commentTextField: UITextField?
        
                ac.addTextField { (textField) in
                    textField.placeholder = "Comment:"
                    commentTextField = textField
                }
        
                let addCommentAction = UIAlertAction(title: "Submit", style: .default) { (_) in
        
                    guard let commentText = commentTextField?.text else { return }
        
                    self.postController.addComment(with: commentText, to: &self.post!)
        
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
        ac.addAction(addCommentAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func createComment(_ sender: Any) {
        showCommentActionSheet()


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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
   
}
