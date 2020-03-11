//
//  RecorderViewController.swift
//  LambdaTimeline
//
//  Created by Michael on 3/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecorderViewController: UIViewController {

    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.delegate = self
            audioPlayer.isMeteringEnabled = true
        }
    }
    
    var isRecording: Bool {
        return audioRecorder?.isRecording ?? false
    }
    
    var handleView = UIView()
    var recordButton = RecordButton()
    var timeLabel = UILabel()
    var audioView = AudioVisualizerView()
    
    @IBOutlet var recorderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHandelView()
        setupRecordingButton()
        // Do any additional setup after loading the view.
    }
    
    fileprivate func setupHandelView() {
        handleView.layer.cornerRadius = 12
        handleView.backgroundColor = UIColor(r: 208, g: 207, b: 205)
        view.addSubview(handleView)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.widthAnchor.constraint(equalToConstant: 37.5).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        handleView.alpha = 0
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
            audioView.isHidden = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.handleView.alpha = 1
                self.timeLabel.alpha = 1
                self.audioView.alpha = 1
                self.view.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.bounds.width, height: -300)
                self.view.layoutIfNeeded()
            }, completion: nil)
//            self.checkPermissionAndRecord()
            self.requestPermissionOrStartRecording()
        } else {
            audioView.isHidden = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.handleView.alpha = 0
                self.timeLabel.alpha = 0
                self.audioView.alpha = 0
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 198)
                self.view.layoutIfNeeded()
            }, completion: nil)
//            self.stopRecording()
            
        }
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("We need microphone access")
                    return
                }
                
                print("Recording permission has been granted!")
                // NOTE: Invite the user to tap record again, since we just interrupted them, and they may not have been ready to record
            }
        case .denied:
            print("Microphone access has been blocked.")
            
            let alertController = UIAlertController(title: "Microphone Access Denied", message: "Please allow this app to access your Microphone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        case .granted:
            startRecording()
        @unknown default:
            break
        }
    }

    func startRecording() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        let recordingURL = createNewRecordingURL()
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: format)
        audioRecorder?.record()
        
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        self.recordingURL = recordingURL
        
    }
    
    func stopRecording() {
        audioRecorder?.stop()
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(file)")
        
        return file
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

extension RecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard let recordingURL = recordingURL else { return }
        
        audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) // TODO: handle error
        
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Error recording: \(error)")
        }
    }
}

extension RecorderViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayDidFinishPlaying.flag = \(flag)")
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Error decoding audio: \(error)")
        }
    }
}
