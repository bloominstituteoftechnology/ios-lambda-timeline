//
//  ViewController.swift
//  ImageFilters
//
//  Created by Jorge Alvarez on 3/9/20.
//  Copyright © 2020 Jorge Alvarez. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        print("Add")
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("Save")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Test")
    }


}

