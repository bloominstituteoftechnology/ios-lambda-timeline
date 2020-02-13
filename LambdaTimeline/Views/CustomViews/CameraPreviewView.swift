//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Chad Rutherford on 2/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { videoPlayerView.session }
        set { videoPlayerView.session = newValue }
    }
}
