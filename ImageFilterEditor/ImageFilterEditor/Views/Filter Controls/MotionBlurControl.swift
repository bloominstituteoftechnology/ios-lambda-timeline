//
//  MotionBlurControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class MotionBlurControl: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var angleSlider: UISlider!
    @IBOutlet weak var radiusSlider: UISlider!
    
    
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
    @IBAction func save(_ sender: Any) {
        
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        
    }
}
