//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Elizabeth Wingate on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

@available(iOS 13.0, *)
class CameraViewController: UIViewController {
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    //MARK: Outlets
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!
    
    //MARK: Properties
    var postController: PostController!
    var player: AVPlayer!
    var recordURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCaptureSession()
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
    
      private func setUpCaptureSession() {
         captureSession.beginConfiguration()
         
         let camera = bestCamera()
         
         // Video
         guard let captureInput = try? AVCaptureDeviceInput(device: camera),
             captureSession.canAddInput(captureInput) else {
                 fatalError("Can't create the input form the camera")
         }
         captureSession.addInput(captureInput)
         
         if captureSession.canSetSessionPreset(.hd1920x1080) {
             captureSession.sessionPreset = .hd1920x1080
         }
         
         // Audio
         let microphone = bestAudio()
         guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
             captureSession.canAddInput(audioInput) else {
                 fatalError("Can't create microphone input")
         }
         captureSession.addInput(audioInput)
        
         guard captureSession.canAddOutput(fileOutput) else {
             fatalError("Cannot record to disk")
         }
         captureSession.addOutput(fileOutput)
         
         captureSession.commitConfiguration()
        
         cameraView.session = captureSession
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        fatalError("No audio")
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        if let wideCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideCamera
        }
        fatalError("No cameras on the device (or you're running this on a Simulator which isn't supported)")
    }
    
      private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
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

    //MARK: Actions
    
   @IBAction func recordButtonPressed(_ sender: Any) {
         if fileOutput.isRecording {
        fileOutput.stopRecording()
    } else {
        deletePreviousRecording()
        newRecordingURL()
        guard let recordURL = recordURL else { return }
        fileOutput.startRecording(to: recordURL, recordingDelegate: self)
      }
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



@available(iOS 13.0, *)
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
