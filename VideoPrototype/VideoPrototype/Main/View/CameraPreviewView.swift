//
//  CameraPreviewView.swift
//  VideoPrototype
//
//  Created by Kenny on 6/3/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import Foundation

import UIKit
import AVFoundation

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
