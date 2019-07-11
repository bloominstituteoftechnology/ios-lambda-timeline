import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {

    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!


    private var captureSession: AVCaptureSession!
    private var recordOutput: AVCaptureMovieFileOutput!


    override func viewDidLoad() {
        super.viewDidLoad()
        setupCapture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        captureSession.startRunning()
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        captureSession.stopRunning()
    }


    func updateViews() {
        guard isViewLoaded else { return }
        let recordButtonImageName = recordOutput.isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImageName)!, for: .normal)
    }


    @IBAction func toggleRecording(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }

    }

    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }

    // MARK: - AVCaptureFileOutputRecordingDelegate

    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }



    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()

            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized {
                    NSLog("Please give app access to your photos in settings")
                    return
                }

                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
                }, completionHandler: { (success, error) in
                    if let error = error {
                        NSLog("Error saving video to photo library: \(error)")
                    }
                })
            })

        }
    }

    // MARK: - Setup Recording

    private func setupCapture() {
        let captureSession = AVCaptureSession()
        let device = bestCamera()

        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
        }




        captureSession.addInput(videoDeviceInput)

        let fileOutput = AVCaptureMovieFileOutput()

        guard captureSession.canAddOutput(fileOutput) else { fatalError() }

        captureSession.addOutput(fileOutput)

        captureSession.sessionPreset = .hd1920x1080
        captureSession.commitConfiguration()

        self.recordOutput = fileOutput
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession

    }



    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device")
        }
    }




}
