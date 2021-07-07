//
//  CommentVideoTableViewCell.swift
//  LambdaTimeline
//
//  Created by Vici Shaweddy on 1/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol CommentVideoTableViewCellDelegate: AnyObject {
    func didPressPlayButton(tag: Int)
}

class CommentVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    weak var delegate: CommentVideoTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playPressed(_ sender: Any) {
         self.delegate?.didPressPlayButton(tag: self.tag)
    }
}
