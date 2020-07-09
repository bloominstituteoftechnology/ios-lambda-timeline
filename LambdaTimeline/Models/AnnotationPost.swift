//
//  AnnotationPost.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/3/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import MapKit

class AnnotationPost: NSObject, MKAnnotation {

	let post: Post
	let latitude: Double
	let longitude: Double

	var title: String? {
		post.title
	}
	var subtitle: String? {
		post.author.displayName
	}
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}

	init?(post: Post) {
		guard let lat = post.latitude, let long = post.longitude else { return nil }
		self.latitude = lat
		self.longitude = long
		self.post = post
		super.init()
	}
}
