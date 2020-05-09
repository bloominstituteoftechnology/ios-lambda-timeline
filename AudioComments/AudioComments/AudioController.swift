////
////  AudioController.swift
////  AudioComments
////
////  Created by Jessie Ann Griffin on 5/8/20.
////  Copyright © 2020 Jessie Griffin. All rights reserved.
////
//
//import Foundation
//import AVFoundation
//
//class AudioController {
//
//    weak var timer: Timer?
//
//    private lazy var timeIntervalFormatter: DateComponentsFormatter = {
//        let formatting = DateComponentsFormatter()
//        formatting.unitsStyle = .positional // 00:00  mm:ss
//        formatting.zeroFormattingBehavior = .pad
//        formatting.allowedUnits = [.minute, .second]
//        return formatting
//    }()
//
//    deinit {
//        timer?.invalidate()
//    }
//
//    func startTimer(for audioElement: AVAudioPlayer) {
//            timer?.invalidate()
//
//            timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
//                guard let self = self else { return }
//
//                self.updateViews()
//
//                if let audioCommentRecorder = self.audioCommentRecorder,
//                    self.isRecording == true {
//
//                    audioCommentRecorder.updateMeters()
//                    self.audioVisualizer.addValue(decibelValue: audioCommentRecorder.averagePower(forChannel: 0))
//                }
//    //
//    //            if let audioPlayer = self.audioPlayer,
//    //                self.isPlaying == true {
//    //                audioPlayer.updateMeters()
//    //                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
//    //            }
//            }
//        }
//
//    func startTimer(for audioElement: AVAudioRecorder) {
//            timer?.invalidate()
//
//            timer = Timer.scheduledTimer(withTimeInterval: 0.030, repeats: true) { [weak self] (_) in
//                guard let self = self else { return }
//
//                self.updateViews()
//
//                if let audioCommentRecorder = self.audioCommentRecorder,
//                    self.isRecording == true {
//
//                    audioCommentRecorder.updateMeters()
//                    self.audioVisualizer.addValue(decibelValue: audioCommentRecorder.averagePower(forChannel: 0))
//                }
//    //
//    //            if let audioPlayer = self.audioPlayer,
//    //                self.isPlaying == true {
//    //                audioPlayer.updateMeters()
//    //                self.audioVisualizer.addValue(decibelValue: audioPlayer.averagePower(forChannel: 0))
//    //            }
//            }
//        }
//        func cancelTimer() {
//            timer?.invalidate()
//            timer = nil
//        }
//}
