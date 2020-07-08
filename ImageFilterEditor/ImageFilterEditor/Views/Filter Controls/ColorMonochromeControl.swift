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
    
    private var filters = Filters()
    var image: UIImage?
    var delegate: FilteredImageDelegate?
    private let ciColors: [CIColor] = [.black, .red, .blue, .green, .yellow, .cyan, .gray]
    private let uiColors: [UIColor] = [.black, .red, .blue, .green, .yellow, .cyan, .gray]
    private let colorNames: [String] = ["Black", "Red", "Blue", "Green", "Yellow", "Cyan", "Gray"]
    
    
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
    @IBAction func stepperTapped(_ sender: UIStepper) {
        updateViews()
    }
    
    @IBAction func filter(_ sender: Any) {
        guard let image = image else { return }
        
        let filteredimage = filters.colorMonochrome(for: image,
                                                    color: ciColors[Int(colorStepper.value)],
                                                    intensity: intensitySlider.value)
        delegate?.filteredImage(filteredimage)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate?.saveCurrentImage()
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        colorStepper.value = 0.0
        colorStepper.isUserInteractionEnabled = true
        colorPreview.textColor = .black
        colorPreview.text = "Black"
        
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 1
        intensitySlider.value = 0.5
        intensitySlider.isUserInteractionEnabled = true
        
        colorStepper.minimumValue = 0
        colorStepper.maximumValue = 6
        colorStepper.stepValue = 1
        colorStepper.isContinuous = true
        colorStepper.value = 0
        colorStepper.isUserInteractionEnabled = true
        colorStepper.wraps = true
    }
    
    private func updateViews() {
        colorPreview.textColor = uiColors[Int(colorStepper.value)]
        colorPreview.text = colorNames[Int(colorStepper.value)]
    }
}

