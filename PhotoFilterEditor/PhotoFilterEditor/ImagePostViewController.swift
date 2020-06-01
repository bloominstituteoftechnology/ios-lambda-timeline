//
//  ImagePostViewController.swift
//  PhotoFilterEditor
//
//  Created by Bhawnish Kumar on 6/1/20.
//  Copyright © 2020 Bhawnish Kumar. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {

    @IBOutlet weak var choosePhotoOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choosePhotoOutlet.layer.cornerRadius = 12
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

}
