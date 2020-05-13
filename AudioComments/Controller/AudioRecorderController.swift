//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by Christian Lorenzo on 5/12/20.
//  Copyright © 2020 Christian Lorenzo. All rights reserved.
//

import UIKit
import AVFoundation


class AudioController: UIViewController {
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
            //audioPlayer.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    weak var timer: Timer?
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    
    
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var recordButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    
    private lazy var timeInternalFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()
    
    //Methods:
    
    func updateViews() {
        
    }
    
    func prepareForAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) //Can fail if you're on a phone call.
    }
    
    func play() {
        do {
            try prepareForAudioSession()
            audioPlayer?.play()
            //start timer when function is programmed
            //startTimer()
        } catch {
            print("There was an error playing back the audio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        //Need to add cancel timer call
        //cancelTimer
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        print("Recording URL: \(recordingURL)")
        
        return file
    }
    
    func requestPermissionToStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { (granted) in
                guard granted == true else {
                    print("We need Mic access to record")
                    return
                }
                
                print("Record permission has been granted!")
            }
        case .denied:
            print("Microphone access has been blocked!")
            
            let alertController = UIAlertController(title: "Microphone access denied!", message: "Please allow this app to access your mic please...", preferredStyle: .alert)
            
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
        do {
            try prepareForAudioSession()
        } catch {
            print("Error!")
            return
        }
        
        recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        do {
            audioRecorder = try AVAudioRecorder(url: <#T##URL#>, format: <#T##AVAudioFormat#>)
        }
    }

}
