//
//  Filters.swift
//  LambdaTimeline
//
//  Created by Kenny on 6/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

enum Filter: String, CaseIterable {
    case gaussian = "CIGaussianBlur"
    case checkerboard = "CICheckerboardGenerator"
    case contrast = "CIColorControls"
    case sepia = "CISepiaTone"
    case bloom = "CIBloom"
}
