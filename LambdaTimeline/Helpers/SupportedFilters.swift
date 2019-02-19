//
//  SupportedFilters.swift
//  LambdaTimeline
//
//  Created by Dillon McElhinney on 2/18/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import CoreImage

let supportedFilters: [String: CIFilter] = [
    "Hue": CIFilter(name: "CIHueAdjust")!,
    "Brightness/Contrast/Saturation": CIFilter(name: "CIColorControls")!,
    "Blur": CIFilter(name: "CIDiscBlur")!,
    "Crystallize": CIFilter(name: "CICrystallize")!
]
