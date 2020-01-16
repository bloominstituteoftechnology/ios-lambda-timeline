//
//  PostDetailViewController.swift
//  LambdaTimeline
//
//  Created by Jon Bash on 2020-01-15.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class PostDetailViewController: UITableViewController {
    
    var post: Post!
    var mediaData: Data?

    var postController: PostController!

    var avManageable: AVManageable? { nil }

    private var operations = [String: Operation]()
    private let mediaFetchQueue = OperationQueue()
    private let cache = Cache<String, Data>()

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        if let manageable = avManageable {
            AVManager.shared.add(manageable)
        }
    }

    func updateViews() {
        guard isViewLoaded else { return }
        
        title = post?.title

        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }

    @IBAction func commentButtonTapped(_ sender: Any) {
        createComment()
    }

    // MARK: - Create Comments

    func createComment() {
        let selectTypeAlert = UIAlertController(
            title: "Select comment style",
            message: "What type of comment would you like to leave?",
            preferredStyle: .actionSheet)
        selectTypeAlert.addAction(UIAlertAction(
            title: "Text",
            style: .default,
            handler: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.createTextComment()
                }
        }))
        selectTypeAlert.addAction(UIAlertAction(
            title: "Audio",
            style: .default,
            handler: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.createAudioComment()
                }
        }))
        selectTypeAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil))
        present(selectTypeAlert, animated: true, completion: nil)
    }

    private func createTextComment() {
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)

        var commentTextField: UITextField?

        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }

        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            guard let commentText = commentTextField?.text else { return }

            self.postController.addComment(withText: commentText, to: &self.post)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(addCommentAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    private func createAudioComment() {
        AVManager.shared.pauseAll()
        performSegue(withIdentifier: "MakeAudioComment", sender: nil)
    }

    // MARK: - Table view data source

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return (post?.comments.count ?? 0) - 1
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let comment = post?.comments[indexPath.row + 1]
        if let commentText = comment?.text {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "TextCommentCell",
                for: indexPath)
            cell.textLabel?.text = commentText
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
        } else if let comment = comment,
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "AudioCommentCell",
                for: indexPath)
                as? AudioCommentTableViewCell {
            cell.authorLabel.text = comment.author.displayName
            AVManager.shared.add(cell.audioPlayerControl)
            loadCommentAudio(for: comment, in: cell, at: indexPath)
            return cell
        } else {
            return UITableViewCell()
        }
    }

    // MARK: - Fetch Comment Data

    private func loadCommentAudio(
        for comment: Comment,
        in commentCell: AudioCommentTableViewCell,
        at indexPath: IndexPath
    ) {
        let commentID = String(indexPath.row + 1)
        if let audioData = cache.value(for: commentID) {
            setMediaData(audioData, for: commentCell)
            return
        }

        guard
            let audioURL = comment.audioURL,
            let fetchOp = FetchCommentMediaOperation(
                mediaURL: audioURL,
                postController: postController)
            else {
                print("could not make fetch op")
                return
        }
        let cacheOp = BlockOperation { [weak self] in
            if let data = fetchOp.mediaData {
                self?.cache.cache(value: data, for: commentID)
                DispatchQueue.main.async {
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
        let completionOp = BlockOperation { [weak self] in
            defer { self?.operations.removeValue(forKey: commentID) }

            if let currentIndexPath = self?.tableView.indexPath(for: commentCell),
                currentIndexPath != indexPath {
                print("Got data for now-reused cell")
                return
            }

            if let data = fetchOp.mediaData {
                self?.setMediaData(data, for: commentCell)
            }
        }

        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)

        mediaFetchQueue.addOperation(fetchOp)
        mediaFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)

        operations[commentID] = fetchOp
    }

    private func setMediaData(_ mediaData: Data, for commentCell: AudioCommentTableViewCell) {
        commentCell.audioPlayerControl.loadAudio(from: mediaData)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let audioCommentVC = segue.destination as? AudioCommentViewController {
            audioCommentVC.post = post
            audioCommentVC.postController = postController
            audioCommentVC.delegate = self
        }
    }
}

// MARK: - Comment Delegate

extension PostDetailViewController: AudioCommentViewControllerDelegate {
    func didSuccessfullyLeaveAudioComment() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
