//
//  VideoPostCollectionViewCell.swift
//  LambdaTimeline
//
//  Created by Lambda_School_Loaner_204 on 1/15/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var labelBackgroundView: UIView!

    var player: AVPlayer?

    func loadVideo(data: Data) {
        // local
        let url: URL = newLocalVideoURL()
        do {
            try data.write(to: url)
            setUpPlayerAndView(with: AVPlayerItem(url: url))
        } catch {
            print("Error writing to local file")
        }
    }

    private func setUpPlayerAndView(with playerItem: AVPlayerItem) {
        player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)

        playerLayer.frame = videoView.frame
        playerLayer.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer)
    }

    var post: Post? {
        didSet {
            updateViews()
        }
    }

    func updateViews() {
        guard let post = post else { return }

        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupLabelBackgroundView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        //imageView.image = nil
        titleLabel.text = ""
        authorLabel.text = ""
    }

    func setupLabelBackgroundView() {
        labelBackgroundView.layer.cornerRadius = 8
        //        labelBackgroundView.layer.borderColor = UIColor.white.cgColor
        //        labelBackgroundView.layer.borderWidth = 0.5
        labelBackgroundView.clipsToBounds = true
    }

    private func newLocalVideoURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let name = formatter.string(from: Date())
        let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
        return fileURL
    }
}
