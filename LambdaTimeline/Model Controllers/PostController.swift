//
//  PostController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class PostController {
    
    func createPost(with title: String, ofType mediaType: MediaType, mediaData: Data, ratio: CGFloat? = nil, completion: @escaping (Bool) -> Void = { _ in }) {
        
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else { return }
        
        store(mediaData: mediaData, mediaType: mediaType) { (mediaURL) in
            
            guard let mediaURL = mediaURL else { completion(false); return }
            
            let imagePost = Post(title: title, mediaURL: mediaURL, ratio: ratio, mediaType: mediaType, author: author)
            
            self.postsRef.childByAutoId().setValue(imagePost.dictionaryRepresentation) { (error, ref) in
                if let error = error {
                    NSLog("Error posting image post: \(error)")
                    completion(false)
                }
        
                completion(true)
            }
        }
    }
    
    func addComment(with text: String, to post: Post) {
        
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else { return }
        
        let comment = Comment(text: text, author: author)
        post.comments.append(comment)
        
        savePostToFirebase(post)
    }
    
    func addComment(with url: URL, to post: Post, completion: @escaping () -> Void) {
        guard let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser) else { return }
        
        
        let soundData = try! FileHandle(forUpdating: url).readDataToEndOfFile()
        
        store(mediaData: soundData, mediaType: .audio) { mediaURL in
            guard let mediaURL = mediaURL,
                let newFileLocation = self.getDocumentsURLFromURL(mediaURL) else { return }
            
            do {
                try FileManager.default.moveItem(at: url, to: newFileLocation)
            } catch {
                NSLog("Error moving audio file: \(error)")
            }
            
            let comment = Comment(audioURL: mediaURL, author: author)
            post.comments.append(comment)
            self.savePostToFirebase(post)
            completion()
        }
        
    }
    
    func getIDFromURL(_ url: URL) -> String? {
        let urlString = url.absoluteString
        print(urlString)
        
        let range = NSRange(location: 0, length: urlString.utf16.count)
        do {
            let regex = try NSRegularExpression(pattern: "(?<=(audio%2F))[A-Z0-9-]*(?=(.alt))")
            if let match = regex.firstMatch(in: urlString, options: [], range: range) {
                let id = urlString[Range(match.range, in: urlString)!]
                return "\(id)"
            }
        } catch {
            NSLog("Error getting ID from URL: \(error)")
        }
        
        return nil
    }
    
    func getDocumentsURLFromURL(_ url: URL) -> URL? {
        guard let id = getIDFromURL(url) else { return nil }
        
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let newFileLocation = documentsDirectory.appendingPathComponent(id)
        
        return newFileLocation
    }

    func observePosts(completion: @escaping (Error?) -> Void) {
        
        postsRef.observe(.value, with: { (snapshot) in
            
            guard let postDictionaries = snapshot.value as? [String: [String: Any]] else { return }
            
            var posts: [Post] = []
            
            for (key, value) in postDictionaries {
                
                guard let post = Post(dictionary: value, id: key) else { continue }
                
                posts.append(post)
            }
            
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            
            completion(nil)
            
        }) { (error) in
            NSLog("Error fetching posts: \(error)")
        }
    }
    
    func savePostToFirebase(_ post: Post, completion: (Error?) -> Void = { _ in }) {
        
        guard let postID = post.id else { return }
        
        let ref = postsRef.child(postID)
        
        ref.setValue(post.dictionaryRepresentation)
    }

    private func store(mediaData: Data, mediaType: MediaType, completion: @escaping (URL?) -> Void) {
        
        let mediaID = UUID().uuidString
        
        let mediaRef = storageRef.child(mediaType.rawValue).child(mediaID)
        
        let uploadTask = mediaRef.putData(mediaData, metadata: nil) { (metadata, error) in
            if let error = error {
                NSLog("Error storing media data: \(error)")
                completion(nil)
                return
            }
            
            if metadata == nil {
                NSLog("No metadata returned from upload task.")
                completion(nil)
                return
            }
            
            mediaRef.downloadURL(completion: { (url, error) in
                
                if let error = error {
                    NSLog("Error getting download url of media: \(error)")
                }
                
                guard let url = url else {
                    NSLog("Download url is nil. Unable to create a Media object")
                    
                    completion(nil)
                    return
                }
                completion(url)
            })
        }
        
        uploadTask.resume()
    }
    
    var posts: [Post] = []
    let currentUser = Auth.auth().currentUser
    let postsRef = Database.database().reference().child("posts")
    
    let storageRef = Storage.storage().reference()
    
    
}
