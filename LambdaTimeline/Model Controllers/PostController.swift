//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation

class PostController {
        
    var posts: [Post] = []
    
    var currentUser: String? {
        UserDefaults.standard.string(forKey: "username")
    }
    
    func createImagePost(with title: String, image: UIImage, ratio: CGFloat?, geotag: CLLocationCoordinate2D?) {
        
        guard let currentUser = currentUser else { return }
        
        let post = Post(title: title, mediaType: .image(image), ratio: ratio, geotag: geotag, author: currentUser)
        
        posts.append(post)
    }
    
    func createVideoPost(with title: String, videoURL: URL, geotag: CLLocationCoordinate2D?) {
        guard let currentUser = currentUser else { return }
        let post = Post(title: title, mediaType: .video(videoURL), geotag: geotag, author: currentUser)
        posts.append(post)
    }
    
    func addComment(with text: String, to post: inout Post) {
        
        guard let currentUser = currentUser else { return }
        
        let comment = Comment(text: text, author: currentUser)
        post.comments.append(comment)

    }
    
    func addAudioComment(with url: URL, to post: inout Post) {
        guard let currentUser = currentUser else { return }
        let comment = Comment(audioURL: url, author: currentUser)
        post.comments.append(comment)
    }
    
    func imageFromVideo(url: URL, at time: TimeInterval, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let asset = AVURLAsset(url: url)

            let assetIG = AVAssetImageGenerator(asset: asset)
            assetIG.appliesPreferredTrackTransform = true
            assetIG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels

            let cmTime = CMTime(seconds: time, preferredTimescale: 60)
            let thumbnailImageRef: CGImage
            do {
                thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
            } catch let error {
                print("Error: \(error)")
                return completion(nil)
            }

            DispatchQueue.main.async {
                completion(UIImage(cgImage: thumbnailImageRef))
            }
        }
    }
    
}
