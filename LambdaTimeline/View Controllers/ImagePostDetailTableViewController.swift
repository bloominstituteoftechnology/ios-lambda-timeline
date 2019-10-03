//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: UITableViewController {
	var post: Post!
	var postController: PostController!
	var imageData: Data?
	var videoURL: URL?

	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var authorLabel: UILabel!
	@IBOutlet private weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
	@IBOutlet private var videoPlayerView: VideoPlayerView!


	override func viewDidLoad() {
		super.viewDidLoad()
		updateViews()
	}

	func updateViews() {
		guard let post = post else { return }
		imageView.isHidden = true
		videoPlayerView.isHidden = true

		switch post.mediaType {
		case .image:
			guard let imageData = imageData,
				let image = UIImage(data: imageData) else { return }
			imageView.image = image
			imageView.isHidden = false
		case .video:
			guard let videoURL = videoURL else { return }
			videoPlayerView.isHidden = false
			videoPlayerView.loadMovie(url: videoURL)
			videoPlayerView.shouldLoop = true
			videoPlayerView.play()
		}

		title = post.title
		

		titleLabel.text = post.title
		authorLabel.text = post.author.displayName
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let commentContainerVC = segue.destination as? CommentContainerViewController {
			commentContainerVC.postController = postController
			commentContainerVC.post = post
		}
	}
}

// MARK: - Table view data source
extension ImagePostDetailTableViewController {
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (post?.comments.count ?? 0) - 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: UITableViewCell
		
		let comment = post?.comments[indexPath.row + 1]
		if comment?.audioURL != nil {
			let audioCell = audioCommentCell(at: indexPath)
			audioCell.comment = comment
			cell = audioCell
		} else {
			cell = textCommentCell(at: indexPath)
			cell.textLabel?.text = comment?.text
			cell.detailTextLabel?.text = comment?.author.displayName
		}

		return cell
	}

	private func textCommentCell(at indexPath: IndexPath) -> UITableViewCell {
		tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
	}

	private func audioCommentCell(at indexPath: IndexPath) -> AudioCommentTableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell",
													   for: indexPath) as? AudioCommentTableViewCell
			else { return AudioCommentTableViewCell() }
		return cell
	}

}
