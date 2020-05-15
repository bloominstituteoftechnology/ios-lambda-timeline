//
//  MoviePlayerView.swift
//  VideoPosts
//
//  Created by David Wright on 5/12/20.
//  Copyright © 2020 David Wright. All rights reserved.
//

import UIKit
import AVFoundation

class MoviePlayerView: UIView {
    
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
