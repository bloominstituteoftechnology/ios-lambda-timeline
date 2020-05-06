//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Joshua Rutkowski on 5/6/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    
    //MARK: - IBOutlets

    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    //MARK: - IBActions
    
    @IBAction func actionClickOnCamera(_ sender: UIButton) {
    }
    
    
    @IBAction func actionClickOnGallery(_ sender: UIButton) {
    }
    
}
