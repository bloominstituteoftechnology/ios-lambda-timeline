//
//  VideoPlayerView.swift
//  LambdaTimeline
//
//  Created by Cora Jacobson on 11/5/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var videoPlayerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { return videoPlayerLayer.player }
        set { videoPlayerLayer.player = newValue }
    }
}