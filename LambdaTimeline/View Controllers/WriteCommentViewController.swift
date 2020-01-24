//
//  WriteCommentViewController.swift
//  LambdaTimeline
//
//  Created by John Kouris on 1/18/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class WriteCommentViewController: UIViewController {
    
    let commentTextField = LTTextField()
    let commentButton = UIButton()
    var postController: PostController!
    var post: Post!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureTextField()
        configureCommentButton()
    }
    
    func configureTextField() {
        view.addSubview(commentTextField)
        
        NSLayoutConstraint.activate([
            commentTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCommentButton() {
        view.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.setTitle("Post Comment", for: .normal)
        commentButton.backgroundColor = .systemBlue
        commentButton.layer.cornerRadius = 10
        
        commentButton.addTarget(self, action: #selector(postComment), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            commentButton.topAnchor.constraint(equalTo: commentTextField.bottomAnchor, constant: 40),
            commentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            commentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            commentButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func postComment() {
        guard let commentText = commentTextField.text else { return }
        self.postController.addComment(with: commentText, to: &self.post)
        navigationController?.popViewController(animated: true)
    }

}
