//
//  VideoPlayerView.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/3/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {
    override class var layerClass: AnyClass {
        AVPlayerLayer.self
    }
    
    var videoPlayerLayer: AVPlayerLayer {
        layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            videoPlayerLayer.player
        }
        set {
            videoPlayerLayer.player = newValue
        }
    }
}
