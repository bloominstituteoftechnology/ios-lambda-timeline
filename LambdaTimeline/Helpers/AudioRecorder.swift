//
//  AudioRecorder.swift
//  LambdaTimeline
//
//  Created by Michael Redig on 10/1/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import AVFoundation

protocol AudioRecorderDelegate: AnyObject {
	func recorderDidChangeState(_ recorder: AudioRecorder)
	func recorderDidFinishSavingFile(_ recorder: AudioRecorder, url: URL)
}

class AudioRecorder: NSObject {
	static var newTmpFilehandle: URL {
		let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
		let name = UUID().uuidString

		let file = tmpDir.appendingPathComponent(name).appendingPathExtension("caf")
		return file
	}

	private let avRecorder: AVAudioRecorder
	weak var delegate: AudioRecorderDelegate?

	var isRecording: Bool {
		avRecorder.isRecording
	}

	/// initializes a new recording to the file location specified
	init(recordingTo file: URL) throws {
		guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { fatalError("Bad audio format") }
		avRecorder = try AVAudioRecorder(url: file, format: format)
		avRecorder.prepareToRecord()
		super.init()
		avRecorder.delegate = self
	}

	/// initializes a new recording to the tmp directory
	override init() {
		let file = AudioRecorder.newTmpFilehandle

		guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1) else { fatalError("Bad audio format") }
		do {
			avRecorder = try AVAudioRecorder(url: file, format: format)
		} catch {
			NSLog("Error creating recording: \(error)")
			fatalError("Error creating recording: \(error)")
		}
		avRecorder.prepareToRecord()

		super.init()
		avRecorder.delegate = self
	}

	func record() {
		avRecorder.record()
		notifyDelegate()
	}

	func stop() {
		avRecorder.stop() // save to disk
		notifyDelegate()
	}

	func toggleRecording() {
		if isRecording {
			stop()
		} else {
			record()
		}
	}

	private func notifyDelegate() {
		delegate?.recorderDidChangeState(self)
	}
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("audioRecorderEncodeErrorDidOccur: \(error)")
        }
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		delegate?.recorderDidFinishSavingFile(self, url: recorder.url)
    }
}
