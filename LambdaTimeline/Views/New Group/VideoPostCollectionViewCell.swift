//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoPostCollectionViewCell: UICollectionViewCell {
    
    
    var videoPost: VideoPost? {
        didSet {
            updateViews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        
        titleLabel.text = ""
        authorLabel.text = ""
    }
    
    func updateViews() {
        guard let videoPost = videoPost else { return }
        
        titleLabel.text = videoPost.title 
        authorLabel.text = videoPost.author.displayName
    }
    
    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        labelBackgroundView.clipsToBounds = true
    }
    
    
    
    
    @IBOutlet weak var VideoLayerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!
    
}
