//
//  VideoContainer.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoContainer: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}
