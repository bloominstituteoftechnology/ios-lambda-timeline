//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImagePostDetailTableViewController: PostDetailViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    override func updateViews() {
        super.updateViews()
        guard
            let imageData = mediaData,
            let image = UIImage(data: imageData)
            else { return }
        
        imageView.image = image
    }
}
