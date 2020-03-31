//
//  FilteredImage.swift
//  LambdaTimeline
//
//  Created by Jeffrey Santana on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

enum FilterType : String {
	case Original = "Original"
	case Chrome = "CIPhotoEffectChrome"
	case Fade = "CIPhotoEffectFade"
	case Instant = "CIPhotoEffectInstant"
	case Mono = "CIPhotoEffectMono"
	case Noir = "CIPhotoEffectNoir"
	case Process = "CIPhotoEffectProcess"
	case Tonal = "CIPhotoEffectTonal"
	case Transfer =  "CIPhotoEffectTransfer"
	
	var regularText: String {
		self.rawValue.replacingOccurrences(of: "CIPhotoEffect", with: "")
	}
}

class FilterController {
	private var filteredImages = [UIImage]()
	private let image: UIImage?
	let filters: [FilterType] = [.Original, .Chrome, .Fade, .Instant, .Noir]
	
	init(image: UIImage?) {
		self.image = image
	}
	
	func createFilters(completion: @escaping () -> Void) {
		guard let image = image else { return }
		DispatchQueue.global().sync {
			for filter in self.filters {
				let filteredImage = image.addFilter(filter: filter) ?? image
				self.filteredImages.append(filteredImage)
			}
			completion()
		}
	}
	
	func getFilter(at index: Int) -> (type: FilterType, image: UIImage) {
		(filters[index], filteredImages[index])
	}
}
