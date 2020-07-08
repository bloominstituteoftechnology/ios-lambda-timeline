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
    
    var delegate: FilteredImageDelegate?
    
    
    //MARK: - Life Cycles -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        //not sure if this or the below is right will test both
        //        Bundle.main.loadNibNamed("MotionBlurControl", owner: self, options: nil)
        //        addSubview(contentView)
        //        contentView.frame = self.bounds
        //        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        let name = String(describing: type(of: self))
        let nib = UINib(nibName: name, bundle: .main)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
}

