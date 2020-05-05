//
//  ImageFilterViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

protocol ImageFilterDelegate {
    func imageFilterDidProcessOutput(image: UIImage)
}

class ImageFilterController: UINavigationController {
    
    // MARK: - Public Properties
    
    var animationDuration = 0.3
    var inputImage: UIImage?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        
        if let selectFilterVC = viewControllers.first as? SelectFilterViewController {
            selectFilterVC.animationDuration = animationDuration
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        self.preferredContentSize = container.preferredContentSize
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
