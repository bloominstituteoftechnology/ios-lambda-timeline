//
//  ImagePostDetailTableViewCell.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_204 on 1/14/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var audioPlayButton: UIButton!

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }

    private func updateViews() {
        
    }

}
