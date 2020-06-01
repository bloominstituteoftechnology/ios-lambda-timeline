//
//  ViewController.swift
//  ImageFilterEditor
//
//  Created by Chris Dobek on 6/1/20.
//  Copyright © 2020 Chris Dobek. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos

class ImagePostViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
        let filter = CIFilter.photoEffectMono()
        print(filter)
    }


}

