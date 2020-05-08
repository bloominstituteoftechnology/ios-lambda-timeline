//
//  PostDetailView.swift
//  LambdaTimeline
//
//  Created by Karen Rodriguez on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//
import UIKit

class PostDetailView: UIView {

    // MARK: - Properties
    var post: Post? {
        didSet {
            updateSubviews()
        }
    }

    private let postImage = UIImageView()


    override init(frame: CGRect) {
        super.init(frame: frame)
        postImage.translatesAutoresizingMaskIntoConstraints = false
        addSubview(postImage)

        postImage.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 1).isActive = true
        postImage.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true

//        postImage.heightAnchor.constraint(equalTo: heightAnchor, constant: 1).isActive = true
//        postImage.widthAnchor.constraint(equalTo: widthAnchor, constant: 1).isActive = true

        postImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        postImage.contentMode = .scaleAspectFit

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Private

    private func updateSubviews() {
        guard let url = post?.mediaURL else { return }
        let data = try! Data(contentsOf: url)
        postImage.image = UIImage(data: data)
    }
}
