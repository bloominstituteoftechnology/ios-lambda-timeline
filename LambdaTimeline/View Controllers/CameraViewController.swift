//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Michael Flowers on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    
    private lazy var captureSession = AVCaptureSession() //we want this to be executed at a later time
    private lazy var fileOutput = AVCaptureMovieFileOutput() //will initialize later
    private var player: AVPlayer!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cameraView: CameraPrviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get the camera you want to use
        let camera = bestCamera()
        
        //now that I have a camera, try to capture it's input
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Can't create input from camera.") }
        
        //now we are working for the capture session, which is responsible for orgainziing all of our inputs and outputs
        //setup inputs - verify first
        if captureSession.canAddInput(cameraInput) {
            //if you canADD it.....ADD it
            captureSession.addInput(cameraInput)
        }
        
        //set up outputs
        if captureSession.canAddOutput(fileOutput){
            captureSession.addOutput(fileOutput)
        }
        
        //set the quality video level
        if captureSession.canSetSessionPreset(.hd1920x1080){
            captureSession.canSetSessionPreset(.hd1920x1080)
        }
        
        //Now that I have both the input and output and I've set the quality level, I can now commit/set the configuration
        captureSession.commitConfiguration()
        
        //after configuration add the captureSession to the camerView
        cameraView.session = captureSession
        
        //TODO: ADD PLAYBACK FUNCTION
        
    }
    
    //we have to start the captureSession and we have to stop the capture session.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func updateViews(){
        //we basically want to change the record button's image
        if fileOutput.isRecording {
            recordButton.setImage(UIImage(named: "Stop"), for: .normal)
            recordButton.tintColor = UIColor.black
        } else {
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
            recordButton.tintColor = UIColor.red
        }
    }
    
    //set up the device you want to use on the camera
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back){
                return device
        }
        
        //could not get a camera
        fatalError("No camera exists - you are running on an old ass phone or a simulator.")
    }
    
    //create a url to store  new recoding
    private func newRecordingURL() -> URL {
        //get the documentDirectoryPath
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withInternetDateTime])
        let url = documentDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return url
    }
    
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        print("Record")
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            //in order to record we will need a url save the data to
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    //these two functions are not called on a specific thread.
    
    //Because of the delay in starting and stopping recording, these functions will be trigger when either functions are finished.
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        //this allows us to update the UI, also we want to be sure to update the UI on the main thread.
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    
    
}
