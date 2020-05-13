//
//  VideoPostController.swift
//  VideoPost
//
//  Created by Jessie Ann Griffin on 5/12/20.
//  Copyright © 2020 Jessie Griffin. All rights reserved.
//

import Foundation
import CoreData

class VideoPostController {
    
    init() {
        collectionOfVideos = loadFromPersistentStore()
    }
    
    var collectionOfVideos: [VideoPost] = []
    
    func addVideo(withTitle title: String, andURL url: URL) {
        let video = VideoPost(title: title, url: url)
        collectionOfVideos.append(video)
        saveToPersistentStore()
    }
    
    func delete(video: VideoPost) {
        CoreDataStack.shared.mainContext.delete(video)
        saveToPersistentStore()
    }
    
    func loadFromPersistentStore() -> [VideoPost] {

        let fetchRequest: NSFetchRequest<VideoPost> = VideoPost.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "videoURL", ascending: true)]
        let moc = CoreDataStack.shared.mainContext

        do {
            return try moc.fetch(fetchRequest)
        } catch {
            print("Error fetching from moc: \(error)")
            return []
        }
    }

    func saveToPersistentStore() {
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
}
