//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Isaac Lyons on 12/4/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPreviewView!
    
    //MARK: Properties
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var postController: PostController!
    var player: AVPlayer!
    var recordURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        }
        captureSession.stopRunning()
        deletePreviousRecording()
    }
    
    //MARK: Private
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    private func setUpCamera() {
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            fatalError("Can't create a camera input")
        }
        
        // Add video input
        guard captureSession.canAddInput(cameraInput) else {
            fatalError("Session can't handle this type of input: \(cameraInput)")
        }
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.medium) {
            captureSession.sessionPreset = .medium
        }
        
        // Add audio input
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        guard captureSession.canAddInput(audioInput) else {
            fatalError("Can't add audio input")
        }
        captureSession.addInput(audioInput)
        
        // Add video output
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot record to disk")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
    }

    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        fatalError("No cameras found")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func newRecordingURL() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        
        recordURL = fileURL
    }
    
    private func deletePreviousRecording() {
        let fileManager = FileManager.default
        
        do {
            if let recordURL = recordURL {
                try fileManager.removeItem(at: recordURL)
                self.recordURL = nil
            }
        } catch {
            NSLog("Error deleting previous recording: \(error)")
        }
    }
    
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            deletePreviousRecording()
            newRecordingURL()
            guard let recordURL = recordURL else { return }
            fileOutput.startRecording(to: recordURL, recordingDelegate: self)
        }
    }
    
    //MARK: Actions
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        toggleRecord()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        }
        
        guard let recordURL = recordURL else { return }
        
        let alert = UIAlertController(title: "Add a title", message: "Enter a title below", preferredStyle: .alert)
        
        var titleTextField: UITextField?
        
        alert.addTextField { textField in
            textField.placeholder = "Title"
            titleTextField = textField
        }
        
        let postVideoAction = UIAlertAction(title: "Post Video", style: .default) { _ in
            guard let titleText = titleTextField?.text,
                !titleText.isEmpty else { return }

            do {
                let videoData = try FileHandle(forUpdating: recordURL).readDataToEndOfFile()
                
                self.postController.createPost(with: titleText, ofType: .video, mediaData: videoData) { success in
                    guard success else {
                        NSLog("Error creating post from video at URL: \(recordURL)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                NSLog("Could not get video data: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(postVideoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        }
        
        print(outputFileURL.path)
        updateViews()
    }
}