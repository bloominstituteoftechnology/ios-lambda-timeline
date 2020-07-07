//
//  BloomControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class BloomControl: UIView {
    
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
}

