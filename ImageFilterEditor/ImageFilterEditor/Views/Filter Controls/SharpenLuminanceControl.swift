//
//  SharpenLuminanceControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class SharpenLuminanceControl: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var sharpnessSlider: UISlider!
    
    private var filters = Filters()
    
    
    //MARK: - Life Cycles -
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
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
    //        Bundle.main.loadNibNamed("SharpenLuminanceControl", owner: self, options: nil)
    //        addSubview(contentView)
    //        contentView.frame = self.bounds
    //        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            let name = String(describing: type(of: self))
            let nib = UINib(nibName: name, bundle: .main)
            nib.instantiate(withOwner: self, options: nil)
            
            self.addSubview(self.contentView)
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
                self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }
    
    
    //MARK - Actions -
    @IBAction func filter(_ sender: Any) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        sharpnessSlider.minimumValue = 0
        sharpnessSlider.maximumValue = 20
        sharpnessSlider.setValue(1.69, animated: false)
        
    }
}
