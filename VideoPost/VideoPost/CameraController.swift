//
//  CameraController.swift
//  VideoPost
//
//  Created by Hunter Oppel on 6/4/20.
//  Copyright © 2020 LambdaSchool. All rights reserved.
//

import Foundation
import AVFoundation

class CameraController {
    
    init() {
        setUpCaptureSession()
    }
    
    lazy var captureSession = AVCaptureSession()
    lazy var fileOutput = AVCaptureMovieFileOutput()
    
    private func setUpCaptureSession() {
        captureSession.beginConfiguration()
        
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("")
        }
        
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("")
        }
        captureSession.addInput(audioInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }
        
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        fatalError("")
    }
    
    private func bestAudio() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(for: .audio) {
            return device
        }
        
        fatalError("")
    }
    
    func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
}
