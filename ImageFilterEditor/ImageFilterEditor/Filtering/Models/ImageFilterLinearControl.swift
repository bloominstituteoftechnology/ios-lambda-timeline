//
//  FilterControl.swift
//  ImageFilterEditor
//
//  Created by Shawn Gee on 5/5/20.
//  Copyright © 2020 Swift Student. All rights reserved.
//

import Foundation

struct ImageFilterLinearControl {
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    let label: String
    let filterParameterKey: String
}

protocol ImageFilterLinearControlDelegate: AnyObject {
    func filterControl(_ control: ImageFilterLinearControl, didChangeValueTo value: Float)
}
