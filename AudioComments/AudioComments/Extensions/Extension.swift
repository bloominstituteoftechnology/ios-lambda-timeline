//
//  UIView+Snapshot.swift
//  AudioComments
//
//  Created by Joshua Rutkowski on 5/10/20.
//  Copyright © 2020 Josh Rutkowski. All rights reserved.
//

import UIKit

extension UIView  {
    // render the view within the view's bounds, then capture it as image
  func asImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds)
    return renderer.image(actions: { rendererContext in
        layer.render(in: rendererContext.cgContext)
    })
  }
}

extension Int {
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
}
