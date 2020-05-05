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
    
    var animationDuration = 0.3
    
    var inputImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        self.preferredContentSize = container.preferredContentSize
    }
    
}
