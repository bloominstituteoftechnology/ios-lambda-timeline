//
//  VideoRecorderViewController.swift
//  LambdaTimeline
//
//  Created by Michael on 3/11/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecorderViewController: UIViewController {

    // Add capture session
    lazy var captureSession = AVCaptureSession()
    
    // Add movie output (.mov)
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    
    var player: AVPlayer!
    
    var recordButton = RecordButton()
    
    @IBOutlet var cameraView: CameraPreviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupRecordingButton()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        
        setUpCaptureSession()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           captureSession.startRunning()
           
       }
       
       override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)
           captureSession.stopRunning()
       }
    
    private func setUpCaptureSession() {
        let camera = bestCamera()
        
        captureSession.beginConfiguration()
        
        // Add Inputs
        guard
            let cameraInput = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(cameraInput) else {
                fatalError("Can't create camera with current input")
        }
        captureSession.addInput(cameraInput)
        // TODO: Add Microphonoe
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080 // 1080p
            
        }
        
        // Add Microphone
        let microphone = bestAudio()
        guard let audioInput = try? AVCaptureDeviceInput(device: microphone),
            captureSession.canAddInput(audioInput) else {
                fatalError("Can't create and add input from microphone")
        }
        captureSession.addInput(audioInput)
        
        // Add Outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("")
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
        
        // Ultra wide lens (0.5)
        if let device = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return device
        }
        // Wide angle lens (available on every single iPHone 11)
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        
        // if non of these exist, we'll fatalError() on the simulator
        fatalError("No Camera on device(or you're on the simulator and that isn't supported)")
        
        // Potentially the hardware is missing or is broken (if the user serviced the device, dropped the phone in the pool)
    }
    
    fileprivate func setupRecordingButton() {
        recordButton.isRecording = false
        recordButton.addTarget(self, action: #selector(handleRecording(_:)), for: .touchUpInside)
        view.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 65).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 65 ).isActive = true
    }

    @objc func handleRecording(_ sender: RecordButton) {
            if recordButton.isRecording {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: -300)
                    self.view.layoutIfNeeded()
                }, completion: nil)
                fileOutput.stopRecording()
                print("Stopped Recording")
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 198)
                    self.view.layoutIfNeeded()
                }, completion: nil)
                let url = newRecordingURL()
                print("Started recording: \(url)")
                fileOutput.startRecording(to: url, recordingDelegate: self)
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
    
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
    }
    
    @objc func handleTapGestureRecognizer(_ tapGesture: UITapGestureRecognizer) {
        print("tap")
            switch(tapGesture.state) {
            case .ended:
                replayMovie()
            default:
                print("Handled other states: \(tapGesture.state)")
            }
        }
        
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        var topRect = view.bounds
        topRect.size.height = topRect.height / 2
        topRect.size.width = topRect.width / 2
        topRect.origin.y = view.layoutMargins.top
        
        playerLayer.frame = topRect
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    func replayMovie() {
        guard let player = player else { return }
        player.seek(to: CMTime.zero)
        //CMTime(seconds: 2, preferredTimescale: 30) // 30 Frames per second (FPS)
        player.play()
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

extension VideoRecorderViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        updateViews()
        if let error = error {
            print("Error recording video to \(outputFileURL) \(error)")
            return
        }
        playMovie(url: outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        updateViews()
    }
}
