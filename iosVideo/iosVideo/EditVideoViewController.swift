//
//  EditVideoViewController.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import UIKit
import AVFoundation

class EditVideoViewController: UIViewController {

    var player: AVPlayer!

    var videoURL: URL? {
        didSet {
            playVideo()
        }
    }

    @IBOutlet weak var playerView: VideoPlayerView!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        playVideo()
    }

    private func playVideo() {
        if isViewLoaded {
            guard let url = videoURL else { return }
            player = AVPlayer(url: url)
            playerView.player = player
            player.play()
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem, queue: .main) { [weak self] _ in
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        guard let url = videoURL else { return }
        do {
            try FileManager.default.removeItem(at: url)
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        } catch {
            NSLog("error deleting: \(error)")
        }

    }
}
