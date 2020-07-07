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
    private let ciColors: [CIColor] = [.black, .red, .blue, .green, .yellow, .cyan, .gray]
    private let uiColors: [UIColor] = [.black, .red, .blue, .green, .yellow, .cyan, .gray]
    private let colorNames: [String] = ["Black", "Red", "Blue", "Green", "Yellow", "Cyan", "Gray"]
    private var colorIndex: Int = 0
    
    
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
    //        Bundle.main.loadNibNamed("ColorMonochromeControl", owner: self, options: nil)
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
    
    
    //MARK: - Actions -
    @IBAction func stepperTapped(_ sender: UIStepper) {
        
    }
    
    @IBAction func save(_ sender: Any) {
        
    }
    
    
    //MARK: - Methods -
    private func setUpView() {
        colorStepper.value = 0.0
        colorPreview.textColor = .black
        colorPreview.text = "Black"
        colorIndex = 0
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 1
        intensitySlider.setValue(0.5, animated: false)
    }
}

