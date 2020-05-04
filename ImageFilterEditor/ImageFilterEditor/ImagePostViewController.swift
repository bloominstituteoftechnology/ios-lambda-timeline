//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    @IBOutlet var filterContainerShowConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterContainerShowConstraint.isActive = false
        // Do any additional setup after loading the view.
    }

    // MARK: - Actions
    
    @IBAction func showTools(_ sender: UIBarButtonItem) {
        filterContainerShowConstraint.isActive.toggle()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

