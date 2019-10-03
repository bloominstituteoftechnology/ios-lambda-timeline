//
//  VideoDetailViewController.swift
//  LambdaTimeline
//
//  Created by Bradley Yin on 10/2/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoDetailViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoPreviewView: UIView!
    
    private var player: AVPlayer!
    var postController: PostController!
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self

        requestCameraPermission()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func requestCameraPermission() {
        // get permission, show camera if we have it
        // error condition with lack of permission/restricted
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            requestCameraAccess()
        case .restricted:
            fatalError("inform user cannot use app due to parental restriction")
        case .denied:
            fatalError("ask user to enable camera in Setting> Privacy > Camera")
        case .authorized:
            showCamera()
        }
    }
    private func requestCameraAccess() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                fatalError("please request user to enable camera usage in Setting > Privacy > camera")
            }
            DispatchQueue.main.async {
                self.showCamera()
            }
        }
    }
    private func showCamera() {
        performSegue(withIdentifier: "CameraModalSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CameraModalSegue" {
            guard let cameraVC = segue.destination as? CameraViewController else { fatalError("cant make camera vc") }
            cameraVC.delegate = self
        }
    }
    

    func playMovie(url: URL) {
        player = AVPlayer(url: url)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoPreviewView.bounds
        videoPreviewView.layer.addSublayer(playerLayer)
        
        player.seek(to: .zero)
        
        player.play()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        player.seek(to: .zero)
        player.play()
    }
    @IBAction func postButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, let url = videoURL else { return }
        let data = try! Data(contentsOf: url)
        postController.createPost(with: title, ofType: .video, mediaData: data)
    }
    

}
extension VideoDetailViewController: CameraViewControllerDelegate {
    func passURLToVideoDetailVC(url: URL) {
        playMovie(url: url)
        self.videoURL = url
    }
}
extension VideoDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
