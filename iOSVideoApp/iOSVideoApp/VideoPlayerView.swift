//
//  VideoPlayerView.swift
//  iOSVideoApp
//
//  Created by Ezra Black on 5/6/20.
//  Copyright © 2020 Casanova Studios. All rights reserved.
//

import UIKit
import Foundation
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
