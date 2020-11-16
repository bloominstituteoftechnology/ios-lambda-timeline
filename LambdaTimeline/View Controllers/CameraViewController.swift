//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Kenneth Jones on 11/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class CameraViewController: UIViewController {
    
    var postController: PostController!
    var postTitle = "No Title"
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var getLocation = false
    
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var cameraView: CameraPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView.videoPlayerLayer.videoGravity = .resizeAspectFill
        setupCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }

    private func setupCamera() {
        let camera = bestCamera
        let microphone = bestMicrophone
        
        captureSession.beginConfiguration()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else {
            preconditionFailure("Can't create an input from the camera.")
        }
        
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            preconditionFailure("Can't create an input from the microphone.")
        }
        
        guard captureSession.canAddInput(cameraInput) else {
            preconditionFailure("This session can't handle this type of input: \(cameraInput)")
        }
        
        captureSession.addInput(cameraInput)
        
        guard captureSession.canAddInput(microphoneInput) else {
            preconditionFailure("This session can't handle this type of input: \(microphoneInput)")
        }
        
        captureSession.addInput(microphoneInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            preconditionFailure("This session can't handle this type of output: \(fileOutput)")
        }
        
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        
        cameraView.session = captureSession
    }
    
    private var bestCamera: AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        preconditionFailure("No cameras on device match the specs that we need.")
    }
    
    private var bestMicrophone: AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        preconditionFailure("No microphones on device match the specs that we need.")
    }

    @IBAction func recordButtonPressed(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
    
    func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    func addTitle() {
        let alert = UIAlertController(title: "Add a title", message: "Write your title below:", preferredStyle: .alert)
        
        var titleTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Post Title:"
            titleTextField = textField
        }
        
        let addTitleAction = UIAlertAction(title: "Add Title", style: .default) { (_) in
            
            guard let titleText = titleTextField?.text,
                  !titleText.isEmpty else { return }
            
            self.postTitle = titleText
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addTitleAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func addLocation() {
        let alert = UIAlertController(title: "Add a location", message: "Would you like to include your location in the post?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.locationManager.requestWhenInUseAuthorization()
            self.getLocation = true
            
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            }
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { (_) in
            self.getLocation = false
            self.currentLocation = nil
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
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
        
        print("Video URL: \(outputFileURL)")
        
        addTitle()
        addLocation()
        imageFromVideo(url: outputFileURL, at: 0) { (image) in
            self.postController.createVideoPost(with: self.postTitle, image: image!, video: outputFileURL, ratio: image?.vidRatio, geotag: self.currentLocation)
            
            if self.currentLocation != nil {
                self.postController.createMapPost(with: self.postTitle, location: self.currentLocation!)
            }
        }
        updateViews()
    }
    
}


extension CameraViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        if getLocation {
            currentLocation = locValue
        }
    }
}


extension CameraViewController {
    // Function sourced from StackOverflow to capture an image from the video for use in the PostsCollectionViewController
    public func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)

            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
}
