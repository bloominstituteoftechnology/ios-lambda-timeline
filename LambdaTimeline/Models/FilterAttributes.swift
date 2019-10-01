//
//  FilterAttributes.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 9/30/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreImage

struct FilterAttributes {
	let displayName: String
	let filterName: String
	let attributes: [FilterAttribute]

	struct FilterAttribute: Hashable {
		let displayName: String
		let name: String
		let identity: CGFloat
		let `default`: CGFloat
		let minimum: CGFloat?
		let maximum: CGFloat?
		let sliderMin: CGFloat?
		let sliderMax: CGFloat?
	}

	init?(from filter: CIFilter) {
		let dictionary = filter.attributes
		guard let displayName = dictionary["CIAttributeFilterDisplayName"] as? String,
		let filterName = dictionary["CIAttributeFilterName"] as? String
		else { return nil }

		self.displayName = displayName
		self.filterName = filterName

		let attributes: [FilterAttribute] = dictionary.compactMap {
			guard let attribute = $0.value as? [String: Any] else { return nil }

			guard let defaultValue = attribute[kCIAttributeDefault] as? NSNumber,
				let displayName = attribute[kCIAttributeDisplayName] as? String,
				let identity = attribute[kCIAttributeIdentity] as? NSNumber
			else { return nil }

			let minimum = attribute[kCIAttributeMin] as? NSNumber
			let maximum = attribute[kCIAttributeMax] as? NSNumber
			let sliderMaximum = attribute[kCIAttributeSliderMax] as? NSNumber
			let sliderMinimum = attribute[kCIAttributeSliderMin] as? NSNumber
			let name = $0.key

			let filterAttribute = FilterAttribute(displayName: displayName, name: name, identity: identity.cgFloatValue, default: defaultValue.cgFloatValue, minimum: minimum?.cgFloatValue, maximum: maximum?.cgFloatValue, sliderMin: sliderMinimum?.cgFloatValue, sliderMax: sliderMaximum?.cgFloatValue)
			return filterAttribute
		}

		self.attributes = attributes.sorted { $0.displayName < $1.displayName }
	}
}

extension CIFilter {
	var info: FilterAttributes? {
		return FilterAttributes(from: self)
	}
}

extension NSNumber {
	var cgFloatValue: CGFloat {
		return CGFloat(truncating: self)
	}
}

extension CGFloat {
	var floatValue: Float {
		return Float(self)
	}
}
