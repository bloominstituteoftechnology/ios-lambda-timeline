//
//  NoFilter.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/7/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class NoFilter: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    
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
        Bundle.main.loadNibNamed("NoFilter", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
