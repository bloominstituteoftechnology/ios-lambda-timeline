
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
    
    // Get a capture session
    private let captureSession = AVCaptureSession()
    private let fileOutput = AVCaptureMovieFileOutput()
    
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SESSION INPUTS
        
        // Set up the capture session
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Can't create an input from the camera")
        }
        
        // Make sure my method can handle this kind of input
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("This session can't handle this kind of input")
        }
        captureSession.addInput(cameraInput)
        
        // SESSION OUTPUTS
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to file")
        }
        captureSession.addOutput(fileOutput)
    }
    
    @IBAction func toggleRecord(_ sender: Any) {
        
    }
    
    @IBAction func playbackButton(_ sender: Any) {
        
    }
    
    // MARK: - Private Methods
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        fatalError("We are on a device that doesn't have a camera")
    }
    
    
}
