//
//  VideosCollectionViewCell.swift
//  ImageFilterEditor
//
//  Created by Claudia Maciel on 7/14/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import UIKit
import AVFoundation

class VideosCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var videoPlayerView: VideoPlayerView!
    
    
    // MARK: - Properties
    var videoClip: URL!
    var player: AVPlayer?
    var isPlaying: Bool = false
    
    var post: Post? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Functions
    func updateViews() {
        guard let post = post else { return }
        titleLabel.text = post.title
        
        player = AVPlayer(url: post.mediaURL)
        videoPlayerView.player = player
        videoPlayerView?.videoPlayerLayer.videoGravity = .resizeAspectFill
        player?.actionAtItemEnd = .pause
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        player?.pause()
        player = nil
        post = nil
        isPlaying = false
        imageView?.image = nil
        titleLabel?.text = ""
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMoviePlayerView()
    }
    
       func setupMoviePlayerView() {
           guard let moviePlayerView = videoPlayerView else { return }
           let tapGesture = UITapGestureRecognizer(target: self.videoPlayerView, action: #selector(togglePlayMovie))
           moviePlayerView.addGestureRecognizer(tapGesture)
           
           NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                  object: self.player?.currentItem,
                                                  queue: .main) { [weak self] _ in
                                                   self?.resetMovie()
           }
       }
       
       private func resetMovie() {
           guard let player = player else { return }
           
           player.pause()
           player.seek(to: .zero)
           isPlaying = false
       }
       
       @objc private func togglePlayMovie() {
           guard let player = player else { return }
           
           if isPlaying {
               player.pause()
               isPlaying = false
           } else {
               player.play()
               isPlaying = true
           }
       }
}
