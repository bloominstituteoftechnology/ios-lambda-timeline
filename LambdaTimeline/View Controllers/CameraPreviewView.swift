//
//  CameraPreviewView.swift
//  VideoFilters
//
//  Created by Scott Bennett on 11/7/18.
//  Copyright © 2018 Scott Bennett. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    // Override class so returns preview layer instead of normal layer for smooth video playback
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    // crash if something bad happens
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    
    

}
