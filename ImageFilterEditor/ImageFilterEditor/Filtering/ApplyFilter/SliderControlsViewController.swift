//
//  SliderControlsViewController.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/4/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import UIKit

class SliderControlsViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var filterControls: [ImageFilterLinearControl]?
    weak var delegate: ImageFilterLinearControlDelegate?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSliderControls()
    }
    
    private func setUpSliderControls() {
        guard let filterControls = filterControls else { return }
        
        for (i, filterControl) in filterControls.enumerated() {
            let slider = UISlider()
            slider.minimumValue = filterControl.minValue
            slider.maximumValue = filterControl.maxValue
            slider.value = filterControl.defaultValue
            slider.addTarget(self, action: #selector(handleSliderValueChanged(_:)), for: .valueChanged)
            slider.tag = i
            stackView.addArrangedSubview(slider)
        }
    }
    
    @objc private func handleSliderValueChanged(_ sender: UISlider) {
        guard let filterControls = filterControls else { return }
        let filterControl = filterControls[sender.tag]
        delegate?.filterControl(filterControl, didChangeValueTo: sender.value)
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
