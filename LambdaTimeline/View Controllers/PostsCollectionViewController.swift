//
//  PostsCollectionViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

class PostsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PostControllerAccessor {
	
	var postController: PostController!
	private var operations = [String: Operation]()
	private let mediaFetchQueue = OperationQueue()
	private let cache = Cache<String, Data>()

	@IBOutlet private var emptyCollectionFillView: UIView!
	@IBOutlet private var emptyCollectionViewBG: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		postController?.observePosts { _ in
			DispatchQueue.main.async {
				self.collectionView.reloadData()
			}
		}

		emptyCollectionViewBG.layer.cornerRadius = 20
	}

	private func setupStarterView() {
		emptyCollectionFillView.frame = collectionView.bounds
		emptyCollectionFillView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		view.addSubview(emptyCollectionFillView)
	}

	private func showStarterView(_ show: Bool) {
		if show {
			setupStarterView()
		} else {
			emptyCollectionFillView.removeFromSuperview()
		}
	}
	
	@IBAction func addPost(_ sender: UIBarButtonItem) {
		let alert = UIAlertController(title: "New Post", message: "Which kind of post do you want to create?", preferredStyle: .actionSheet)
		
		let imagePostAction = UIAlertAction(title: "Image", style: .default) { _ in
			self.performSegue(withIdentifier: "AddImagePost", sender: nil)
		}
		let videoPostAction = UIAlertAction(title: "Video", style: .default) { _ in
			self.performSegue(withIdentifier: "AddVideoPost", sender: nil)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		
		alert.addAction(imagePostAction)
		alert.addAction(videoPostAction)
		alert.addAction(cancelAction)

		if UIDevice.current.userInterfaceIdiom == .pad {
			alert.popoverPresentationController?.barButtonItem = sender
		}
		
		self.present(alert, animated: true, completion: nil)
	}
	
	// MARK: UICollectionViewDataSource
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if postController.posts.isEmpty {
			showStarterView(true)
		} else {
			showStarterView(false)
		}
		return postController.posts.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let post = postController.posts[indexPath.row]
		
		switch post.mediaType {
		case .image:
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePostCell",
																for: indexPath) as? ImagePostCollectionViewCell
				else { return UICollectionViewCell() }
			cell.post = post
			loadImage(for: cell, forItemAt: indexPath)
			return cell
		case .video:
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell",
																for: indexPath) as? VideoPostCollectionViewCell
				else { return UICollectionViewCell() }
			cell.post = post
			loadVideo(for: cell, forItemAt: indexPath)
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		var size = CGSize(width: view.frame.width, height: view.frame.width)
		
		let post = postController.posts[indexPath.row]
		
		switch post.mediaType {
		case .image:
			guard let ratio = post.ratio else { return size }
			size.height = size.width * ratio
		case .video:
			size = CGSize(width: view.frame.width, height: view.frame.width)
		}
		
		return size
	}
	
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		
		if let cell = cell as? ImagePostCollectionViewCell,
			cell.imageView.image != nil {
			self.performSegue(withIdentifier: "ViewImagePost", sender: nil)
		}

		if cell is VideoPostCollectionViewCell {
			performSegue(withIdentifier: "ViewImagePost", sender: nil)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView,
								 didEndDisplayingSupplementaryView view: UICollectionReusableView,
								 forElementOfKind elementKind: String,
								 at indexPath: IndexPath) {
		
		guard let postID = postController.posts[indexPath.row].id else { return }
		operations[postID]?.cancel()
	}
	
	func loadImage(for imagePostCell: ImagePostCollectionViewCell, forItemAt indexPath: IndexPath) {
		let post = postController.posts[indexPath.row]
		
		guard let postID = post.id else { return }
		
		if let mediaData = cache.value(for: postID),
			let image = UIImage(data: mediaData) {
			imagePostCell.setImage(image)
			self.collectionView.reloadItems(at: [indexPath])
			return
		}
		
		let fetchOp = FetchMediaOperation(post: post, postController: postController)
		
		let cacheOp = BlockOperation {
			if let data = fetchOp.mediaData {
				self.cache.cache(value: data, for: postID)
				DispatchQueue.main.async {
					self.collectionView.reloadItems(at: [indexPath])
				}
			}
		}
		
		let completionOp = BlockOperation {
			defer { self.operations.removeValue(forKey: postID) }
			
			if let currentIndexPath = self.collectionView?.indexPath(for: imagePostCell),
				currentIndexPath != indexPath {
				print("Got image for now-reused cell")
				return
			}
			
			if let data = fetchOp.mediaData {
				imagePostCell.setImage(UIImage(data: data))
				self.collectionView.reloadItems(at: [indexPath])
			}
		}
		
		cacheOp.addDependency(fetchOp)
		completionOp.addDependency(fetchOp)
		
		mediaFetchQueue.addOperation(fetchOp)
		mediaFetchQueue.addOperation(cacheOp)
		OperationQueue.main.addOperation(completionOp)
		
		operations[postID] = fetchOp
	}

	func loadVideo(for videoPostCell: VideoPostCollectionViewCell, forItemAt indexPath: IndexPath) {
		let post = postController.posts[indexPath.row]

		guard let postID = post.id else { return }

		let cachedMediaURL = getCachedVideo(for: post)!
		let mediaURL = cachedMediaURL.deletingPathExtension()

		if FileManager.default.fileExists(atPath: cachedMediaURL.path) {
			videoPostCell.loadVideo(with: cachedMediaURL)
//			self.collectionView.reloadItems(at: [indexPath])
			return
		}

		let fetchOp = FetchMediaOperation(post: post, postController: postController)

		let cacheOp = BlockOperation {
			if let data = fetchOp.mediaData {
				do {
					try data.write(to: mediaURL)
					try FileManager.default.moveItem(at: mediaURL, to: cachedMediaURL)
				} catch {
					NSLog("Error saving video cache: \(error)")
				}
				DispatchQueue.main.async {
					self.collectionView.reloadItems(at: [indexPath])
				}
			}
		}

		let completionOp = BlockOperation {
			defer { self.operations.removeValue(forKey: postID) }
			self.collectionView.reloadItems(at: [indexPath])
		}

		cacheOp.addDependency(fetchOp)
		completionOp.addDependency(fetchOp)

		mediaFetchQueue.addOperation(fetchOp)
		mediaFetchQueue.addOperation(cacheOp)
		OperationQueue.main.addOperation(completionOp)

		operations[postID] = fetchOp
	}

	private func getCachedVideo(for post: Post) -> URL? {
		guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first, let postID = post.id else { return nil }
		let mediaURL = cacheDir.appendingPathComponent(postID)
		let cachedMediaURL = mediaURL.appendingPathExtension("mov")
		return cachedMediaURL
	}
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if let videoRecordingVC = segue.destination as? VideoRecordingViewController {
			videoRecordingVC.postController = postController
		}

		if segue.identifier == "AddImagePost" {
			let destinationVC = segue.destination as? ImagePostViewController
			destinationVC?.postController = postController
			
		} else if segue.identifier == "ViewImagePost" {
			
			let destinationVC = segue.destination as? ImagePostDetailTableViewController
			
			guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
				let postID = postController.posts[indexPath.row].id else { return }

			let post = postController.posts[indexPath.row]
			destinationVC?.postController = postController
			destinationVC?.post = post
			destinationVC?.imageData = cache.value(for: postID)
			destinationVC?.videoURL = getCachedVideo(for: post)
		}
	}
}
