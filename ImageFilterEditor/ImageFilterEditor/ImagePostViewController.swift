//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private var imageFilterController: ImageFilterController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageFilterController.inputImage = imageView.image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageFilterController {
            imageFilterController = segue.destination as? ImageFilterController
        }
    }
    
    @IBOutlet weak var selectFilterHeightConstraint: NSLayoutConstraint!
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if let imageFilterController = container as? ImageFilterController {
            selectFilterHeightConstraint.constant = imageFilterController.preferredContentSize.height
            UIView.animate(withDuration: imageFilterController.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    
    
}

