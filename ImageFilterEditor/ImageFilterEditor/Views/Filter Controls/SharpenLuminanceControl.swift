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
    var image: UIImage?
    var delegate: FilteredImageDelegate?
    
    
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
    
    
    //MARK - Actions -
    @IBAction func filter(_ sender: Any) {
        guard let image = image else { return }
        
        let filteredImage = filters.sharpenLuminance(for: image,
                                                     sharpness: sharpnessSlider.value)
        delegate?.filteredImage(filteredImage)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.saveCurrentImage()
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        sharpnessSlider.minimumValue = 0
        sharpnessSlider.maximumValue = 20
        sharpnessSlider.setValue(1.69, animated: false)
        sharpnessSlider.isUserInteractionEnabled = true
    }
}
