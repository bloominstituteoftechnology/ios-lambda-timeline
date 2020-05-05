//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var selectFilterHeightConstraint: NSLayoutConstraint!
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if let child = container as? ImageFilterController {
            selectFilterHeightConstraint.constant = child.preferredContentSize.height
            UIView.animate(withDuration: child.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

