//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var imageFilterContainerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Private Properties
    
    private var imageFilterController: ImageFilterController!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageFilterController.inputImage = imageView.image
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
         super.preferredContentSizeDidChange(forChildContentContainer: container)
         if let imageFilterController = container as? ImageFilterController {
             imageFilterContainerHeightConstraint.constant = imageFilterController.preferredContentSize.height
             UIView.animate(withDuration: imageFilterController.animationDuration) {
                 self.view.layoutIfNeeded()
             }
         }
     }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageFilterController {
            imageFilterController = segue.destination as? ImageFilterController
        }
    }
}

