//
//  CameraViewController.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    // MARK: - Properties

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()

    // MARK: - Outlets
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }

    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }

    // Live Preview + inputs/outputs

    private func setUpCaptureSession() {
        // Add inputs
        captureSession.beginConfiguration()
        // Camera input
        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Error adding camera to capture session")
        }
        captureSession.addInput(cameraInput)
        // Microphone input
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        // Add outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: Cannot save movie")
        }
        captureSession.addOutput(fileOutput)

        captureSession.commitConfiguration()
//        cameraView.session = captureSession

        // TODO: Start/Stop session

    }

    private func bestCamera() -> AVCaptureDevice {
        // Ultra-wide lens (iPhone 11 Pro + Pro Max on back)
        if let ultraWideCamera =  AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        // Wide angle lens ( available on any iPhone - front/back)
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        // No cameras present ( simulator )
        fatalError("No camera available - are you on a simmulator?")
    }

    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }

    /// Creates a new file URL in the documents directory
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            // show movie
//            playMovie(url: outputFileURL)
        }
        updateViews()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("startedRecording: \(fileURL)")
        updateViews()
    }
}

