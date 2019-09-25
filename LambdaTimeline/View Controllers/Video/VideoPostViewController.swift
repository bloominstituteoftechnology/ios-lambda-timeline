//
//  VideoPostViewController.swift
//  LambdaTimeline
//
//  Created by Michael Stoffer on 9/24/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostViewController: UIViewController, CameraViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func videoDidFinishRecordingVideo(at url: URL) {
        
        recordVideoButton.setTitle("", for: .normal)
        
        currentVideoURL = url
        
        player = AVQueuePlayer(url: url)
        
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer.frame = videoPlaybackView.frame
        
        playerLooper = AVPlayerLooper(player: player, templateItem: player.items().first!)
        videoPlaybackView.layer.addSublayer(playerLayer)
        videoPlaybackView.playerLayer = playerLayer
        videoPlaybackView.layer.masksToBounds = true
        player.play()
    }
    
    
    @IBAction func createPost(_ sender: Any) {
        
        guard let title = titleTextField.text,
            let url = currentVideoURL else { return }
        
        let videoRect = playerLayer.videoRect
        
        let ratio = videoRect.height / videoRect.width
        
        guard let videoData = try? Data(contentsOf: url) else { return }
        
        let completion: (Bool) -> Void = { _ in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        postController.createPost(with: title, ofType: .video, mediaData: videoData, ratio: ratio, completion: completion)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordVideo" {
            
            player = nil
            
            if playerLayer != nil {
                playerLayer.removeFromSuperlayer()
            }
            
            let destinationVC = segue.destination as? CameraViewController
            
            destinationVC?.delegate = self
        }
    }
    
    var playerLayer: AVPlayerLayer!
    var player: AVQueuePlayer!
    var playerLooper: AVPlayerLooper!
    var currentVideoURL: URL?
    
    var postController: PostController!
    
    @IBOutlet weak var recordVideoButton: UIButton!
    @IBOutlet weak var videoPlaybackView: VideoContainerView!
    @IBOutlet weak var titleTextField: UITextField!
}
