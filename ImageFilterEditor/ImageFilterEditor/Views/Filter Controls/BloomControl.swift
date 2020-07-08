//
//  BloomControl.swift
//  ImageFilterEditor
//
//  Created by Cody Morley on 7/6/20.
//  Copyright © 2020 Cody Morley. All rights reserved.
//

import UIKit

class BloomControl: UIView {
    //MARK: - Properties -
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var intensitySlider: UISlider!
    
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
    
    
    //MARK: - Actions -
    @IBAction func filter(_ sender: Any) {
        guard let image = image else { return }
        
        let filteredImage = filters.bloom(for: image,
                                          with: intensitySlider.value,
                                          radius: radiusSlider.value)
        delegate?.filteredImage(filteredImage)
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    //MARK: - Methods -
    private func setUpView() {
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 1
        intensitySlider.setValue(0.5, animated: false)
        intensitySlider.isUserInteractionEnabled = true
        
        radiusSlider.minimumValue = 0
        radiusSlider.maximumValue = 100
        radiusSlider.setValue(10, animated: false)
        radiusSlider.isUserInteractionEnabled = true
    }
}

