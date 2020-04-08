//
//  CameraViewController+ACCaptureFileOutputRecordingDelegate.swift
//  VideoRecording
//
//  Created by Chris Gonzales on 4/8/20.
//  Copyright © 2020 Chris Gonzales. All rights reserved.
//

import Foundation
import AVFoundation

extension VideoRecordingViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Video Recording Error: \(error)")
        } else {
            playVideoRecording(url: outputFileURL)
        }
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}
