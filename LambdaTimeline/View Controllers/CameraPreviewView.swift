
import UIKit
import AVFoundation

class CameraPreviewView: UIView {

    // When we create an instance of camera preview view, the layer of this view will be an AVCaptureVideoPreviewLayer
    
    override class var layerClass : AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    // Get access to the layer
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        
        // force cast our layer to be an AVCaptureVideoPreviewLayer
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    // Convenience property for accessing/setting the AVCapture session
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }

}
