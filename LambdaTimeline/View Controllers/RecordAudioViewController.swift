//
//  RecordAudioViewController.swift
//  LambdaTimeline
//
//  Created by Jonalynn Masters on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit

protocol RecordAudioViewControllerDelegate: AnyObject {
    func didAddAudioComment(recordAudioViewController: RecordAudioViewController, addedComment: Bool)
}

class RecordAudioViewController: UIViewController {
    // MARK: - Properties & Outlets
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var postButton: UIButton!
    
    lazy private var player = AudioPlayer()
    lazy private var recorder = Record()
    var postController: PostController?
    var post: Post?
    var url: URL?

    weak var delegate: RecordAudioViewControllerDelegate?

    private lazy var timeFormatter: DateComponentsFormatter = {
        let formatting = DateComponentsFormatter()
        formatting.unitsStyle = .positional
        formatting.zeroFormattingBehavior = .pad
        formatting.allowedUnits = [.minute, .second]
        return formatting
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .overCurrentContext
        updateSlider()
        player.delegate = self
        recorder.delegate = self
    }


    // MARK: - IBActions
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        }
    

    @IBAction func playButtonTapped(_ sender: UIButton) {
        player.playPause()
        updateSlider()
    }

    @IBAction func recordButtonTapped(_ sender: UIButton) {
        recorder.toggleRecord()
        
    }

    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let postController = postController,
            let post = post,
            let url = url,
            let recordingData = try? Data(contentsOf: url) else { return }

        postController.addAudioComment(with: recordingData, to: post) {
            self.delegate?.didAddAudioComment(recordAudioViewController: self, addedComment: true)
        }

        dismiss(animated: true, completion: nil)
    }


    // MARK: - Helper Functions

    private func updateSlider() {
        slider.minimumValue = 0
        slider.maximumValue = Float(player.duration)
        slider.value = Float(player.currentTime)
    }

    private func updateViews() {
        updateSlider()
        currentTimeLabel.text = timeFormatter.string(from: player.currentTime)
        timeRemainingLabel.text = timeFormatter.string(from: player.duration)
    }
}


extension RecordAudioViewController: AudioPlayerDelegate {
    func playerDidChangeState(_ player: AudioPlayer) {
        updateViews()
    }
}


extension RecordAudioViewController: RecorderDelegate {
    func recorderDidChangeState(_ recorder: Record) {
        updateViews()
    }

    func recorderDidFinishSavingFile(_ recorder: Record, url: URL) {
        if !recorder.isRecording {
            self.url = url
            print(url)
            do {
                try player.loadAudio(with: url)
            } catch {
                NSLog("Error loading audio with url: \(error)")
            }
        }
    }
}
