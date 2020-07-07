//
//  ColorMonochromeControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class ColorMonochromeControl: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var colorStepper: UIStepper!
    @IBOutlet weak var colorPreview: UILabel!
    @IBOutlet weak var intensitySlider: UISlider!
    
    
    
    //MARK: - Life Cycles -
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
    }
    
    
    //MARK: - Actions -
    @IBAction func stepperTapped(_ sender: UIStepper) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        
    }
    
}

