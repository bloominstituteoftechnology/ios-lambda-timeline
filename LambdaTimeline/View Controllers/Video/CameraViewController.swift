//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

protocol CameraViewControllerDelegate: class {
    func videoDidFinishRecordingVideo(at url: URL)
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureSession = AVCaptureSession()
        let videoDevice = bestCamera()
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(videoDeviceInput) else {
                fatalError()
        }
        captureSession.addInput(videoDeviceInput)
        
        
        let fileOutput = AVCaptureMovieFileOutput()
        guard captureSession.canAddOutput(fileOutput) else { fatalError() }
        captureSession.addOutput(fileOutput)
        recordOutput = fileOutput
        
        captureSession.sessionPreset = .cif352x288
        captureSession.commitConfiguration()
        
        self.captureSession = captureSession
        previewView.videoPreviewLayer.session = captureSession
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    @IBAction func record(_ sender: Any) {
        if recordOutput.isRecording {
            recordOutput.stopRecording()
        } else {
            recordOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async { self.updateViews() }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            
            self.dismiss(animated: true) {
                self.delegate?.videoDidFinishRecordingVideo(at: outputFileURL)
            }
        }
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard isViewLoaded else { return }
        
        let isRecording = recordOutput?.isRecording ?? false
        let recordButtonImage = isRecording ? "Stop" : "Record"
        recordButton.setImage(UIImage(named: recordButtonImage), for: .normal)
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        } else {
            fatalError("Missing expected back camera device.")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDir = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        return documentsDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
    }
    
    // MARK: - Properties
    
    weak var delegate: CameraViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var recordOutput: AVCaptureMovieFileOutput!
    
    @IBOutlet weak var previewView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
}
