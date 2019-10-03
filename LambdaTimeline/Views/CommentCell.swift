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
	
	private var player: AudioPlayer?
	private var audioDataTask: URLSessionDataTask?
	private var audioData: Data? {
		didSet {
			guard let data = audioData else { return }
			player = try? AudioPlayer(with: data)
		}
	}
	var comment: Comment? {
		didSet {
			downloadAudio()
			configCell()
		}
	}
	
	// MARK: - IBActions
	
	@IBAction func playBtnTapped(_ sender: Any) {
		guard let player = player else { return }
		if player.isPlaying {
			player.stop()
		} else {
			player.play()
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
				try player?.load(url: audioUrl)
			} catch {
				NSLog("Could not play audio comment")
			}
		} else {
			playBtn.isHidden = true
			commentLbl.text = comment.text
		}
	}
	
	private func downloadAudio() {
		guard let audioUrl = comment?.audioURL else { return }
		audioDataTask?.cancel()
		audioDataTask = URLSession.shared.dataTask(with: audioUrl, completionHandler: { (data, _, error) in
			if let error = error {
				NSLog("Error donloading audio data: \(error)")
				return
			}
			
			DispatchQueue.main.async {
				self.audioData = data
			}
		})
		audioDataTask?.resume()
	}
}
