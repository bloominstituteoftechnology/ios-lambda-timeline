//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import MapKit

// MARK: - MediaType

enum MediaType {
    case image(ratio: CGFloat?)
    case audio
    case video(ratio: CGFloat?)

    var rawValue: String {
        switch self {
        case .image:
            return "image"
        case .audio:
            return "audio"
        case .video:
            return "video"
        }
    }

    init?(rawValue: String) {
        switch rawValue {
        case "image":
            self = .image(ratio: nil)
        case "audio":
            self = .audio
        case "video":
            self = .video(ratio: nil)
        default:
            return nil
        }
    }
}


class Post {

    // MARK: - Properties

    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var geotag: CLLocationCoordinate2D?
    var mapAnnotation: PostAnnotation? { PostAnnotation(post: self) }

    var ratio: CGFloat? {
        if case .image(let ratio) = mediaType {
            return ratio
        } else if case .video(let ratio) = mediaType {
            return ratio
        } else { return nil }
    }
    var title: String? {
        return comments.first?.text
    }
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [
            Post.mediaKey: mediaURL.absoluteString,
            Post.mediaTypeKey: mediaType.rawValue,
            Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
            Post.authorKey: author.dictionaryRepresentation,
            Post.timestampKey: timestamp.timeIntervalSince1970,
            Post.geotagKey: [Post.latitudeKey: geotag?.latitude,
                             Post.longitudeKey: geotag?.longitude]]

        guard let ratio = self.ratio else { return dict }

        dict[Post.ratioKey] = ratio

        return dict
    }

    // MARK: - Static

    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let geotagKey = "geotag"
    static private let latitudeKey = "latitude"
    static private let longitudeKey = "longitude"

    // MARK: - Init
    
    init(
        title: String,
        mediaURL: URL,
        mediaType: MediaType,
        author: Author,
        timestamp: Date = Date(),
        geotag: CLLocationCoordinate2D? = nil
    ) {
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.geotag = geotag
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard
            let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]]
            else { return nil }
        let geotagRep = dictionary[Post.geotagKey] as? [String: Double]
        
        self.mediaURL = mediaURL
        switch  mediaType {
        case .image:
            self.mediaType = .image(ratio: dictionary[Post.ratioKey] as? CGFloat)
        default:
            self.mediaType = mediaType
        }
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        if let lat = geotagRep?[Post.latitudeKey],
            let long = geotagRep?[Post.longitudeKey] {
            self.geotag = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }
}
