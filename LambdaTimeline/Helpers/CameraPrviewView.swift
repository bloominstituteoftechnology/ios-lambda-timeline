//
//  CameraPrviewView.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraPrviewView: UIView {

    override class var layerClass: AnyClass {
        //the layer is designed to display videa data, for real time viewing
        return AVCaptureVideoPreviewLayer.self
    }
    
    //create the layer as a videoPreviewLayer
    var videoPlayerView: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    //creat the session that we are going to use for the input and output
    var session: AVCaptureSession? {
        get { return videoPlayerView.session }
        set { return videoPlayerView.session = newValue }
    }

}
