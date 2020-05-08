//
//  ImageViewController.swift
//  ImageFilterEditor
//
//  Created by Alex Thompson on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreImage

enum FilterType: Int {
    case exposure
    case vibrance
    case vignette
    case sepia
    case motionBlur
}

class ImageViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var adjustmentSlider: UISlider!
    @IBOutlet var secondAdjustmentSlider: UISlider!
    @IBOutlet var saveButton: UIButton!
    
    let context = CIContext()
    var filterType: FilterType = .exposure
    let effextNames: [String] = ["Exposure",
                                 "Vibrance",
                                 "Sepia Tone",
                                 "Motion Blur"
    ]
    
    let effectImages: [UIImage] = [UIImage(systemName: "sun.max")!,
                                   UIImage(systemName: "sunrise")!,
                                   UIImage(systemName: "smallcircle.circle")!,
                                   UIImage(systemName: "eyedropper.halffull")!,
                                   UIImage(systemName: "slider.horizontal.3")!
    ]
    
    var originalImage: UIImage? {
        didSet {
            //resize the scaledImage
            guard let originalImage = originalImage else { return }
            
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale
            scaledSize = CGSize(width: scaledSize.width, height: scaledSize.width * scale)
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
