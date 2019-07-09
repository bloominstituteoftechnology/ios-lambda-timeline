//
//  AudioCommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Jonathan Ferrer on 7/9/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentTableViewCell: UITableViewCell {

    @IBAction func playButtonPressed(_ sender: Any) {
    }


    @IBOutlet weak var authorLabel: UILabel!
    var comment: Comment?

}
