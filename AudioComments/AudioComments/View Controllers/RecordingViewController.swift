//
//  RecordingViewController.swift
//  AudioComments
//
//  Created by Mark Gerrior on 5/5/20.
//  Copyright © 2020 Mark Gerrior. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {

    // MARK: - Properites
    weak var delegate: PlaybackTableViewController!

    var recordingURL: URL?
    var audioRecorder: AVAudioRecorder?

    // MARK: - Actions

    @IBAction func recordButton(_ sender: Any) {
        requestPermissionOrStartRecording()
    }

    @IBAction func stopButton(_ sender: Any) {
        audioRecorder?.stop()
    }

    @IBAction func cancelButton(_ sender: Any) {
        audioRecorder?.stop()
        let success = audioRecorder?.deleteRecording()
        if let success = success {
            if success {
                print("Recording Canceled")
            } else {
                print("Failed to Cancel Recording.")
            }
        } else {
            print("Unabled to Cancel Recording.")
        }

        navigationController?.popViewController(animated: true)
    }

    @IBAction func sendButton(_ sender: Any) {

        if let recordingURL = recordingURL {
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            let date = df.string(from: Date())

            print("Send: \(recordingURL.absoluteString)")
            print(date)
            delegate?.elements.append((date, recordingURL))
            print("elements.count \(delegate?.elements.count ?? 0)")
        }

        navigationController?.popViewController(animated: true)
    }

    // MARK: - Outlets

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - Private
    private func createNewRecordingURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let name = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: .withInternetDateTime)
        let file = documents.appendingPathComponent(name, isDirectory: false).appendingPathExtension("caf")

        return file
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
        recordingURL = createNewRecordingURL()

        guard let recordingURL = recordingURL else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
        audioRecorder = try? AVAudioRecorder(url: recordingURL, format: format) // TODO: Error handling do/catch
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }

}

extension RecordingViewController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag,
            let recordingURL = recordingURL {
            let playbackAudioPlayer = try? AVAudioPlayer(contentsOf: recordingURL) // TODO: Error handling

            if let _ = playbackAudioPlayer {
                print("Saved recording to \(recordingURL)")
            } else {
                print("Nothing to playback")
            }

            // Dispose of recorder (otherwise I can still cancel and it will delete the recording!)
            audioRecorder = nil
        }
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            print("Audio Record Error: \(error)")
        }
    }
}
