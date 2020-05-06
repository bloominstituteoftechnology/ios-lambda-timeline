//
//  FileManagerController.swift
//  iosVideo
//
//  Created by Karen Rodriguez on 5/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation
import AVFoundation

class FilesController {

    func fetchAllVideos() -> [URL] {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        var urls: [URL] = []

        do {
            let data = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            for path in data {
                if let urlPath = URL(string: path) {
                    urls.append(urlPath)
                }
            }
        } catch {
            NSLog("Error fetching all existing video at path \(documentsDirectory.absoluteString): \(error)")
        }

        return urls
    }
}
