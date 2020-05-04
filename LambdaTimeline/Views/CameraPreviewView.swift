//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Ufuk Türközü on 08.04.20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    var session: AVCaptureSession? {
        get { return videoPlayerView.session }
        set { videoPlayerView.session = newValue }
    }
}
