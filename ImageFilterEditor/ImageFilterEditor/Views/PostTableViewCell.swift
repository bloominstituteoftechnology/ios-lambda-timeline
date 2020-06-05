//
//  PostTableViewCell.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/4/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageTitle: UILabel!
    
    var filteredImage: Image? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let filteredImage  = filteredImage else { return }
        imageTitle.text = "   \(filteredImage.title ?? "")"
        imageView!.image = UIImage(data: filteredImage.image!)
    }
    
}
