//
//  VideoContainerView.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_218 on 2/13/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

class VideoContainerView: UIView {
    var playerLayer: CALayer?
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        playerLayer?.frame = self.bounds
    }
}
