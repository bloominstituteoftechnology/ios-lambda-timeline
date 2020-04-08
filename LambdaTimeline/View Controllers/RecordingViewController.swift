//
//  RecordingViewController.swift
//  LambdaTimeline
//
//  Created by Enrique Gongora on 4/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var recordingTextField: UITextField!
    @IBOutlet var cameraPreview: CameraPreviewView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Properties
    var postController: PostController!
    var videoPost: VideoPost?
    private var fileURL: URL?
    private lazy var captureSession = AVCaptureSession()
    private lazy var fileOutput = AVCaptureMovieFileOutput()
    var isRecording: Bool {
        fileOutput.isRecording
    }
    
    // MARK: - View LifeCycle
    
}
