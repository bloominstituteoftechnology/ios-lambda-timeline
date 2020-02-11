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
import MapKit

class PostController {

    var posts: [Post] = []
    let currentUser = Auth.auth().currentUser
    let postsRef = Database.database().reference().child("posts")

    let storageRef = Storage.storage().reference()
    
    func createPost(
        with title: String,
        ofType mediaType: MediaType,
        mediaData: Data,
        geotag: CLLocationCoordinate2D? = nil,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        guard
            let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser)
            else { return }
        
        store(mediaData: mediaData, mediaType: mediaType, storageReference: storageRef) { mediaURL in
            guard let mediaURL = mediaURL else {
                completion(false)
                return
            }

            let post = Post(
                title: title,
                mediaURL: mediaURL,
                mediaType: mediaType,
                author: author,
                geotag: geotag)
            
            self.postsRef.childByAutoId()
                .setValue(post.dictionaryRepresentation)
                { error, ref in

                if let error = error {
                    NSLog("Error posting image post: \(error)")
                    completion(false)
                    return
                }
        
                completion(true)
            }
        }
    }
    
    func addComment(withText text: String, to post: inout Post) {
        guard
            let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser)
            else { return }
        
        let comment = Comment(text: text, author: author)
        post.comments.append(comment)
        
        savePostToFirebase(post)
    }

    func addComment(
        withAudioData audioData: Data,
        to post: Post,
        completion: @escaping (Bool) -> Void
    ) {
        guard
            let currentUser = Auth.auth().currentUser,
            let author = Author(user: currentUser)
            else { return }

        store(mediaData: audioData,
              mediaType: .audio,
              storageReference: storageRef
        ) { [weak self] url in
            guard let url = url else {
                print("failed to create audio comment")
                completion(false)
                return
            }

            let comment = Comment(audioURL: url, author: author)
            post.comments.append(comment)

            self?.savePostToFirebase(post)
            completion(true)
        }
    }

    func observePosts(completion: @escaping (Error?) -> Void) {
        postsRef.observe(.value, with: { snapshot in
            guard let postDictionaries = snapshot.value as? [String: [String: Any]]
                else { return }
            
            var posts: [Post] = []
            
            for (key, value) in postDictionaries {
                guard let post = Post(dictionary: value, id: key)
                    else { continue }
                posts.append(post)
            }
            
            self.posts = posts.sorted(by: { $0.timestamp > $1.timestamp })
            
            completion(nil)
            
        }) { error in
            NSLog("Error fetching posts: \(error)")
        }
    }
    
    func savePostToFirebase(_ post: Post, completion: (Error?) -> Void = { _ in }) {
        guard let postID = post.id else { return }
        
        let ref = postsRef.child(postID)
        ref.setValue(post.dictionaryRepresentation)
    }

    private func store(
        mediaData: Data,
        mediaType: MediaType,
        storageReference: StorageReference,
        completion: @escaping (URL?) -> Void
    ) {
        let mediaID = UUID().uuidString
        let mediaRef = storageReference.child(mediaType.rawValue).child(mediaID)
        
        let uploadTask = mediaRef.putData(mediaData, metadata: nil) { metadata, error in
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
}
