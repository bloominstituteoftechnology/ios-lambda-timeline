//
//  CameraViewController.swift
//  LambdaTimeline
//
//  Created by Thomas Cacciatore on 7/10/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var postController = PostController()
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!

    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    private var player: AVPlayer!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let camera = bestCamera()
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera) else { fatalError("Can't create input from camera") }
        
        
        // setup inputs
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
        }
        
        guard let microphone = AVCaptureDevice.default(for: .audio) else {
            fatalError("Can't find microphone")
        }
        
        guard let microphoneInput = try? AVCaptureDeviceInput(device: microphone) else {
            fatalError("Can't create input from microphone")
        }
        
        if captureSession.canAddInput(microphoneInput) {
            captureSession.addInput(microphoneInput)
        }
        
        //setup outputs
        
        if captureSession.canAddOutput(fileOutput) {
            captureSession.addOutput(fileOutput)
        }
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.canSetSessionPreset(.hd1920x1080)
        }
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    
    @objc func handleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        //play movie
        if let player = player {
            player.seek(to: CMTime.zero)
            player.play()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func bestCamera() -> AVCaptureDevice {
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return device
        }
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return device
        }
        fatalError("No cameras exist")
    }
    
    func newRecordingURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = "movie"
        let url = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        print("URL: \(url)")
        return url
    }
    
    func updateViews() {
        if fileOutput.isRecording {
            recordButton.setImage(UIImage(named: "Stop"), for: .normal)
            recordButton.tintColor = UIColor.black
        } else {
            recordButton.setImage(UIImage(named: "Record"), for: .normal)
            recordButton.tintColor = UIColor.red
        }
    }
    
    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        var topRect = self.view.bounds
        topRect.size.width = topRect.width / 4
        topRect.size.height = topRect.height / 4
        topRect.origin.y = view.layoutMargins.top
        playerLayer.frame = topRect
        
        view.layer.addSublayer(playerLayer)
        
        player.play()
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            fileOutput.startRecording(to: newRecordingURL(), recordingDelegate: self)
        }
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.updateViews()
        }
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            self.updateViews()
            self.playMovie(url: outputFileURL)
            group.leave()
        }

        //  Wait for playmovie to finish then present alert.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            let alert = UIAlertController(title: "New Post", message: "Add a title and save video", preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "Enter title"
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                guard let newTitle = textField?.text, !newTitle.isEmpty else { return }
                //create post and send to Firebase
                self.postController.createPost(with: newTitle, ofType: .video, mediaData: try! Data(contentsOf: outputFileURL))
                self.navigationController?.popViewController(animated: true)
            }))
            
            self.present(alert, animated:true, completion: nil)
            }
        }
    
        
    
    
    
}
    
    

