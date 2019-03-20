//
//  RecordingTableViewCell.swift
//  LambdaTimeline
//
//  Created by Moses Robinson on 3/20/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    private func updateViews() {
        
        
    }
    
    // MARK: - Properties

    var comment: Comment? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    
}
