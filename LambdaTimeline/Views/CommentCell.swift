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
	
	var comment: Comment? {
		didSet {
			configCell()
		}
	}
	
	// MARK: - IBActions
	
	@IBAction func playBtnTapped(_ sender: Any) {
	}
	
	// MARK: - Helpers
	
	private func configCell() {
		
	}
}
