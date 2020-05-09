//
//  ImagePostTableViewCell.swift
//  ImageFilterEditor
//
//  Created by denis cedeno on 5/7/20.
//  Copyright © 2020 DenCedeno Co. All rights reserved.
//

import UIKit

class ImagePostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageComment: UILabel!
    
    var filteredImage: FilteredImage? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let filteredImage  = filteredImage else { return }
        imageComment.text = "   \(filteredImage.comments ?? "")"
        imageView!.image = UIImage(data: filteredImage.image!)
    }
    
}

