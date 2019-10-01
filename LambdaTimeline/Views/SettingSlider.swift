//
//  SettingSlider.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

protocol SettingSliderDelegate: AnyObject {
	func settingSlider(_ settingSlider: SettingSlider, changedValue value: Float)
}

class SettingSlider: UIView {
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var slider: UISlider!

	weak var delegate: SettingSliderDelegate?

	var title: String {
		get {
			titleLabel.text ?? ""
		}
		set {
			titleLabel.text = newValue
		}
	}

	var value: Float {
		get {
			slider.value
		}
		set {
			slider.value = newValue
		}
	}

	var maxValue: Float {
		get {
			slider.maximumValue
		}
		set {
			slider.maximumValue = newValue
		}
	}

	var minValue: Float {
		get {
			slider.minimumValue
		}
		set {
			slider.minimumValue = newValue
		}
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
		let nib = UINib(nibName: "SettingSlider", bundle: nil)
		nib.instantiate(withOwner: self, options: nil)

		addSubview(contentView)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
	}

	@IBAction func sliderValueChanged(_ sender: UISlider) {
		delegate?.settingSlider(self, changedValue: sender.value)
	}
}
