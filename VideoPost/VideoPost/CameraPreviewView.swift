//
//  CameraPreviewView.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/3/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get {
            videoPlayerView.session
        }
        set {
            videoPlayerView.session = newValue
        }
    }
}
