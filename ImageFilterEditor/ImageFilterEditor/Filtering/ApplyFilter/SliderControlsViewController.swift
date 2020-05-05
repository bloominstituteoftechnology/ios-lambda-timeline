//
//  SliderControlsViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

protocol SliderControlsDelegate {
    func sliderAt(index: Int, didChangeValueTo value: Double)
}

class SliderControlsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var filterControls: [ImageFilterControl]?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setUpSliderControls() {
        guard let filterControls = filterControls else { return }
        
        for filterControl in filterControls {
            let slider = UISlider()
            stackView.addArrangedSubview(slider)
        }
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
