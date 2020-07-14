//
//  CellCommentPostDetailTableViewCell.swift
//  LambdaTimeline
//
//  Created by Jarren Campos on 7/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class CellCommentPostDetailTableViewCell: UITableViewCell {
    @IBOutlet var commentMessageLabel: UILabel!
    @IBOutlet var commentAuthorLabel: UILabel!
    @IBOutlet var playVoiceMessage: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
