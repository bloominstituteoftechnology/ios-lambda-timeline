//
//  CameraController.swift
//  VideoPrototype
//
//  Created by Kenny on 6/3/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraUIDelegate: AVCaptureFileOutputRecordingDelegate {
    func playMovie(url: URL)
    var cameraView: CameraPreviewView! { get set }
}

class CameraController {
    // MARK: - Properties -
    weak var delegate: CameraUIDelegate?
    lazy var captureSession = AVCaptureSession()
    lazy var fileOutput = AVCaptureMovieFileOutput()
    var player: AVPlayer?

    var isRecording: Bool {
        fileOutput.isRecording
    }

    // MARK: Init
    init(delegate: CameraUIDelegate?) {
        self.delegate = delegate
    }

    // MARK: - Permission -
    func requestPermissionAndShowCamera(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                completion(true)
            }
        case .denied:
            // FIXME: Open settings app
            fatalError("Show user UI to get them to give access")
        case .notDetermined:
            requestCameraPermission() { status in
                completion(status)
            }
        case .restricted:
            // Parental Controls,
            // FIXME: alert your parental controls have restricted your use of the camera
            // FIXME: Open Settings with Alert.showWithYesNoPrompt
            fatalError("Show user alert for parental controls")
        @unknown default:
            fatalError("Apple added another enum value that we're not handling")
        }
    }

    private func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else { fatalError("access denied") }
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }

    // MARK: - CaptureSession -
    func setupCaptureSession() {
        //Camera
        captureSession.beginConfiguration()
        defer {
            captureSession.commitConfiguration()
            delegate?.cameraView.session = captureSession
        }
        let camera = bestCamera()

        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput)
        else { fatalError("Cannot create camera input, do something better than crashing?") }
        captureSession.addInput(cameraInput)
        // Quality
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        }

        //Outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Cannot add movie recording. File error")
        }
        captureSession.addOutput(fileOutput)
    }

    private func bestCamera() -> AVCaptureDevice {
        if let ultraWideCamera = AVCaptureDevice.default(
            .builtInUltraWideCamera,
            for: .video,
            position: .back
            ) {
            return ultraWideCamera
        }
        if let wideAngleCamera = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
            ) {
            return wideAngleCamera
        }
        fatalError("This operation requires a camera!")
    }

    func startRecording(to recordingDelegate: AVCaptureFileOutputRecordingDelegate) {
        fileOutput.startRecording(
            to: newRecordingURL(),
            recordingDelegate: recordingDelegate
        )
    }

    func stopRecording() {
        fileOutput.stopRecording()
    }

    private func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }

}
