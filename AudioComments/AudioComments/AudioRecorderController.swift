//
//  AudioRecorderController.swift
//  AudioComments
//
//  Created by Alex Thompson on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorderController: UIViewController {
    
    var audioPlayer: AVAudioPlayer? {
        didSet {
            guard let audioPlayer = audioPlayer else { return }
            
//            audioPlayer.delegate = self
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    weak var timer: Timer?
    
    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
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
    
    func updateViews() {
        
    }
    
    func prepareAudioSession() throws {
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, options: [.defaultToSpeaker])
        try session.setActive(true, options: []) // Can fail if you're on a phone call
    }
    
    func play() {
        do {
            try prepareAudioSession()
            audioPlayer?.play()
            // MARK: - TODO, ADD IN START TIMER FUNCTION WHEN READY!!!!!!!!!
            // start time when function is programmed
            // startTimer()
        } catch {
            print("There was an error playing back audio: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        // MARK: - TODO NEED TO ADD CANCEL TIMER CALL
        //cancelTimer()
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        
        print("recording URL: \(recordingURL!)")
        
        return file
    }
    
    func requestPermissionOrStartRecording() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                guard granted == true else {
                    print("WE NEED MIC ACCESS PRETTY PLEASE WITH CHERRY ON TOP")
                    return
                }
                
                print("Recording permission has been granted!")
            }
        case .denied:
            print("Microphone acces has been blocked!")
        default:
            <#code#>
        }
    }
}
