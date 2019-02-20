//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Benjamin Hakes on 2/19/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit

class AudioCommentViewController: UIViewController, PlayerDelegate, RecorderDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let fontSize = UIFont.systemFontSize
        let font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
        timeLabel.font = font
        remainingTimeLabel.font = font
        setupViews()
        recorder.delegate = self
        player.delegate = self
        
    }
    
    
    private func setupViews() {
        recordButton.layer.cornerRadius = 12
        playButton.layer.cornerRadius = 12
        audioCommentTitleTextField.layer.cornerRadius = 0
        postCommentButton.layer.cornerRadius = 12
        containerView.layer.cornerRadius = 16
        cancelButton.layer.cornerRadius = 16
    }
    
    // MARK - PlayerDelegate Methods
    func playerDidChangeState(_ player: Player) {
        updateViews()
        
    }
    
    func recorderDidChangeState(_ recorder: Recorder) {
        updateViews()
    }
    
    // MARK - Private Methods
    
    private func updateViews(){
        
        let isPlaying = player.isPlaying
        playButton.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        timeSlider.maximumValue = Float(player.songDuration)
        
        timeLabel.text = timeFormatter.string(from: player.elapsedTime)
        
        remainingTimeLabel.text = timeFormatter.string(from: player.remainingTime)
        
        timeSlider.setValue(Float(player.elapsedTime), animated: true)
        
        let isRecording = recorder.isRecording
        recordButton.setTitle(isRecording ? "Stop" : "Record", for: .normal)
    }
    
    
    // MARK: - Actions
    
    @IBAction func tappedPlayButton(_ sender: Any) {
        player.playPause(song: recorder.currentFile)
    }
    @IBAction func recordButtonTapped(_ sender: Any) {
        recorder.toggleRecording()
    }
    @IBAction func tappedCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tappedPostCommentButton(_ sender: Any) {
        
        
        if let post = post {
            guard let commentText = audioCommentTitleTextField?.text else { return }
            
            guard let currentFile = recorder.currentFile else { return }
            
            let audioData =  try! Data(contentsOf: currentFile)
            
            self.postController.store(mediaData: audioData, mediaType: .audioComment) { url in
                
                self.postController.addCommentWithAudio(with: commentText, audioURL: url!, to: post)
                DispatchQueue.main.async {
                    self.imagePostDVC?.tableView.reloadData()
                }
            }
            
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet var playButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var audioCommentTitleTextField: UITextField!
    @IBOutlet var postCommentButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    private var player = Player()
    private let recorder = Recorder()
    var post: Post?
    var postController: PostController = PostController()
    var imagePostDVC: ImagePostDetailTableViewController?
    private lazy var timeFormatter: DateComponentsFormatter = {
        let f = DateComponentsFormatter()
        f.unitsStyle = .positional
        f.zeroFormattingBehavior = .pad
        f.allowedUnits = [.minute, .second]
        return f
    }()
    
}
