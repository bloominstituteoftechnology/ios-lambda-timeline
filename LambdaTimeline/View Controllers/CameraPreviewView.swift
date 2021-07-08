//
//  CameraPreviewView.swift
//  LambdaTimeline
//
//  Created by Yvette Zhukovsky on 1/16/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
}

