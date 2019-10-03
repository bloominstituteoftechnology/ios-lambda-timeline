//
//  CommentCell.swift
//  LambdaTimeline
//
//  Created by Jeffrey Santana on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

	// MARK: - IBOutlets
	
	@IBOutlet weak var initialsLbl: UILabel!
	@IBOutlet weak var commentLbl: UILabel!
	@IBOutlet weak var playBtn: UIButton!
	
	// MARK: - Properties
	
	private lazy var player = AudioPlayer()
	var comment: Comment? {
		didSet {
			configCell()
		}
	}
	
	// MARK: - IBActions
	
	@IBAction func playBtnTapped(_ sender: Any) {
		if player.isPlaying {
			player.stop()
//			playBtn.layer.removeAllAnimations()
//			playBtn.transform = .identity
		} else {
			player.play()
//			UIView.animate(withDuration: player.duration) {
//				self.playBtn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
//			}
		}
	}
	
	// MARK: - Helpers
	
	private func configCell() {
		guard let comment = comment else { return }
		var initials = ""
		
		comment.author.displayName?.components(separatedBy: " ").forEach({ (name) in
			initials += String(name.first!)
		})
		
		initialsLbl.text = initials
		
		if let audioUrl = comment.audioURL {
			commentLbl.text = "Audio File"
			do {
				try player.load(url: audioUrl)
			} catch {
				NSLog("Could not play audio comment")
			}
		} else {
			playBtn.isHidden = true
			commentLbl.text = comment.text
		}
	}
}
