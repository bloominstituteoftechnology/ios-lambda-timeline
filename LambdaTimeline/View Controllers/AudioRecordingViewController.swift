//
//  AudioRecordingViewController.swift
//  LambdaTimeline
//
//  Created by Nick Nguyen on 4/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer



class AudioRecordingViewController: UIViewController
{
    //MARK:- Properties
    
    var songURL: URL?
    var audioPlayer: AVAudioPlayer? {    didSet {   audioPlayer?.isMeteringEnabled = true   }    }
     
  
    
//MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
         pickerController.delegate = self
        view.addSubview(musicView)
        view.addSubview(playButton)
        view.addSubview(browseFileButton)
        view.addSubview(recordButton)
           view.addSubview(timeLabel)
        view.addSubview(horizontalStackView)
     
        
        horizontalStackView.addArrangedSubview(playButton)
        horizontalStackView.addArrangedSubview(browseFileButton)
        horizontalStackView.addArrangedSubview(recordButton)
        
        setUpConstraintsForMusicViewandTimeLabel()
        layoutStackView()
        
        
        setUpNavigationItem()
    }
  
    //MARK:- Properties
    
    private let musicView: UIImageView = {
        let image = UIImage(systemName: "music.note")?.withTintColor(.black)
       let view = UIImageView(image: image )
        view.tintColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = view.frame.height / 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 5
        return view
    }()
    private let playButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.tintColor = .white
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
  
    private let browseFileButton : UIButton = {
       let button = UIButton()
        button.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        button.backgroundColor = .link
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleBrowse), for: .touchUpInside)
        return button
    }()
    
    private let timeLabel: UILabel = {
       let lb = UILabel()
        lb.translatesAutoresizingMaskIntoConstraints = false
        lb.text = "00:00"
        lb.font = UIFont.boldSystemFont(ofSize: 40)
        return lb
    }()
    
    private let recordButton: UIButton = {
       let button =  UIButton()
        button.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        button.setImage(UIImage(systemName: "waveform"), for: .selected)
        button.backgroundColor = .red
        button.tintColor = .white
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleRecord), for: .touchUpInside)
        
        
        return button
    }()
    
    // Record
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    var isRecording: Bool { return audioRecorder?.isRecording ?? false  }
        
    private let pickerController : MPMediaPickerController = {
           let pc = MPMediaPickerController(mediaTypes: .anyAudio)
           pc.allowsPickingMultipleItems = true
           pc.prompt = NSLocalizedString("Choose audio file", comment: "Pick an audio file for comment")
           return pc
       }()
     
     private let horizontalStackView: UIStackView = {
        let stackView = UIStackView()
         stackView.alignment = .fill
         stackView.distribution = .fillEqually
         stackView.axis = .horizontal
         stackView.translatesAutoresizingMaskIntoConstraints = false
         stackView.spacing = 10
         return stackView
     }()
    
    private func createNewRecordingURL() -> URL {
           let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           
           let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
           let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
           
           print("recording URL: \(file)")
           
           return file
       }
    
     private func requestPermissionOrStartRecording() {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    guard granted == true else {
                        print("We need microphone access")
                        return
                    }
                    
                    print("Recording permission has been granted!")
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
   private func startRecording() {
       let recordingURL = createNewRecordingURL()

        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        
        self.recordingURL = recordingURL
        do {
              audioRecorder = try AVAudioRecorder(url: recordingURL, format: audioFormat)
        } catch let err as NSError {
            print(err.localizedDescription)
            return
        }
      
        audioRecorder?.delegate = self
        audioRecorder?.record()
     
    }
    private lazy var timeIntervalFormatter: DateComponentsFormatter = {

          let formatting = DateComponentsFormatter()
          formatting.unitsStyle = .positional
          formatting.zeroFormattingBehavior = .pad
          formatting.allowedUnits = [.minute, .second]
          return formatting
      }()
   //MARK:- Objc Methods:
    
    @objc func handlePlay() {
        print("play")
        audioPlayer?.play()
        
    }
    //Timer
    
    @objc private func handleRecord() {
        
        if isRecording {
            recordButton.backgroundColor = .red
            recordButton.isSelected = false
            audioRecorder?.stop()
            timer?.invalidate()
            print("stop")
        } else {
            recordButton.backgroundColor = .green
            recordButton.isSelected = true
            startRecording()
            updateTimeLabel()
            print("recording")
        }
        
        
    }
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
        print("Pick music success")
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleBrowse() {
        print("browsing...")
        present(pickerController, animated: true, completion: nil)
        
    }
    
    var timer: Timer?
       var count: TimeInterval = 0
       func updateTimeLabel() {
           timer?.invalidate()
           timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (_) in
               self.count += 1
               self.timeLabel.text = self.timeIntervalFormatter.string(from: self.count)
           })
       }
    
    private func setUpNavigationItem() {
      
        navigationItem.title = "Audio Comment"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pick", style: .done, target: self, action: #selector(handleDone))
        view.backgroundColor = .white
    }
    
    //MARK:- Constraints
    
    private func setUpConstraintsForMusicViewandTimeLabel() {
        NSLayoutConstraint.activate([
                 musicView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 musicView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: -100),
                 musicView.widthAnchor.constraint(equalToConstant: 200),
                 musicView.heightAnchor.constraint(equalToConstant: 200),
                 
                 timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 timeLabel.topAnchor.constraint(equalTo: musicView.bottomAnchor,constant: 40),
             ])
      
    }

    private func layoutStackView() {
         NSLayoutConstraint.activate([
         horizontalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -50),
         horizontalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
         horizontalStackView.widthAnchor.constraint(equalToConstant: 300),
         horizontalStackView.heightAnchor.constraint(equalToConstant: 40)
         ])
       
     }
 
}
//MARK:- Extension
extension NSNotification.Name {
    static let music = NSNotification.Name("Music")
}
extension AudioRecordingViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

          // set up the player the recording
          if let recordingURL = recordingURL {
            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
            
            let userInfo : [String:Any] = ["musicURL": recordingURL]
            NotificationCenter.default.post(name: .music, object: self, userInfo: userInfo)
    
      }
      func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
          if let error = error {
            print("Audio Recorder Error: \(error.localizedDescription)")
            return
          }
      }
}
}
extension AudioRecordingViewController: MPMediaPickerControllerDelegate {
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        //run any code you want once the user has picked their chosen audio
   
        let musicPlayer = MPMusicPlayerController.systemMusicPlayer
        musicPlayer.setQueue(with: mediaItemCollection)
        musicPlayer.play()
        mediaPicker.dismiss(animated: true)
        
        musicPlayer.play()
    }
}

