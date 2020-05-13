//
//  RecordAudioCommentsViewController.swift
//  LambdaTimeline
//
//  Created by Sal B Amer on 5/12/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioURLDelegate: AnyObject {
    func passAudioURL(for url: URL)
}

class RecordAudioCommentViewController: UIViewController {

  
  //Mark: IB Outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var audioVisulizer: AudioVisualizer!
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
 
    
    weak var delegate: AudioURLDelegate?
    var fileURL: URL?
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - Timer
    var timer: Timer?
    
    func startTimer() {
        timer?.invalidate() // Cancel a timeer before you start a new one
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
            guard let self = self else { return }
            
            self.updateViews()
        }
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    
    
    private func updateViews() {
        recordButton.isSelected = isRecording
    }
    
    var audioRecorder: AVAudioRecorder?
    var recordingURL: URL?
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")
        fileURL = file
        
        print("recording URL: \(file)")
        
        return file
    }
    
    func startRecording() {
        let recordingURL = createNewRecordingURL()
        
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: format)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()
        self.recordingURL = recordingURL
        updateViews()
        startTimer()
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        updateViews()
        cancelTimer()
    }
  
  //MARK: IB Actions
  @IBAction func cancelBtnWasPressed(_ sender: UIBarButtonItem) {
   }
   
   @IBAction func saveBtnWasPressed(_ sender: UIBarButtonItem) {
     self.dismiss(animated: true) {
       if let fileURL = self.fileURL {
           self.delegate?.passAudioURL(for: fileURL)
       }
     }
   }
  
  @IBAction func recordBtnTapped(_ sender: UIButton) {
    if isRecording {
      stopRecording()
    } else {
      startRecording()
    }
  }
  
}

extension RecordAudioCommentViewController: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("⚠️ Audio Recorder Error: \(error)")
        }
        updateViews()
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        if flag, let recordingURL = recordingURL {
//            audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) // TODO: Error handling
//        }
        
        updateViews()
    }

}
