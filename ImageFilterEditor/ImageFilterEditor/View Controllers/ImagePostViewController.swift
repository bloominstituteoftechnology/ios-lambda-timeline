//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class ImagePostViewController: UIViewController {
    // MARK: - Properties -
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var filterPicker: UIPickerView!
    
    
    //MARK: - Life Cycles -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - Methods -
    private func updateViews() {
        
    }
    
    private func updateControls() {
        
    }

}

extension ImagePostViewController: UIPickerViewDelegate {
    
}

extension ImagePostViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    
}
