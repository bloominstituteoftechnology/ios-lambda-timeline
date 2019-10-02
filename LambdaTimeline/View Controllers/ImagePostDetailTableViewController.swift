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
        
		title = post.description
        
        imageView.image = image
        
        titleLabel.text = post.description
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
		
		let actionSheet = UIAlertController(title: "Comment Style", message: "How would you like to leave a comment", preferredStyle: .actionSheet)
		let action1 = UIAlertAction(title: "Text", style: .default) { (_) in
			let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
			
			var commentTextField: UITextField?
			
			alert.addTextField { (textField) in
				textField.placeholder = "Comment:"
				commentTextField = textField
			}
			
			let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
				
				guard let commentText = commentTextField?.text else { return }
				
				self.postController.addComment(with: commentText, audioURL: nil, to: &self.post!)
				
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			
			alert.addAction(addCommentAction)
			alert.addAction(cancelAction)
			
			self.present(alert, animated: true, completion: nil)
		}
		let action2 = UIAlertAction(title: "Audio", style: .default) { (_) in
			self.performSegue(withIdentifier: "RecordAudioSegue", sender: nil)
		}
		let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
		[action1, action2, action3].forEach({ actionSheet.addAction($0) })
		present(actionSheet, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post?.comments.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        let comment = post?.comments[indexPath.row]
        
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = comment?.author.displayName
        
        return cell
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let audioCommentVC = segue.destination as? AudioCommentVC {
			audioCommentVC.postController = postController
			audioCommentVC.post = post
		}
	}
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
