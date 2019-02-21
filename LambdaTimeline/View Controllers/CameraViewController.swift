
import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
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
        
        // Tell capture session what resolution of video
        captureSession.sessionPreset = .hd1920x1080
        
        // Commit
        captureSession.commitConfiguration()
        
        // Show the session in the UI
        cameraView.session = captureSession

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func toggleRecord(_ sender: Any) {
        // Check if currently recording
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    @IBAction func playbackButton(_ sender: Any) {
        
    }
    
    @IBAction func postVideo(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Add a title", message: "Create a title for your video", preferredStyle: .alert)
        
        // Confirm action taking the input
        let titleAction = UIAlertAction(title: "Post Video", style: .default) { (_) in
            
            let videoTitle = alertController.textFields?[0].text
            
            var commentTextField: UITextField?
            
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Title:"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(titleAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
            
            
        }
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
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documents = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        
        let name = f.string(from: Date())
        return documents.appendingPathComponent(name).appendingPathExtension("mov")
    }
    
    private func updateViews() {
        let isRecording = fileOutput.isRecording
        recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
    }
    
}
