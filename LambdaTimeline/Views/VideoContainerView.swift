//
//  VideoContainerView.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class VideoContainerView: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}
