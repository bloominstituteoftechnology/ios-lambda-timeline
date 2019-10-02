//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

class Comment: FirebaseConvertible, Equatable {
	private static let textKey = "text"
	private static let author = "author"
	private static let timestampKey = "timestamp"
	private static let audioURLKey = "audioURL"
	
	let text: String?
	let audioURL: URL?
	let author: Author
	let timestamp: Date
	
	init(text: String, author: Author, timestamp: Date = Date()) {
		self.text = text
		self.author = author
		self.timestamp = timestamp
		self.audioURL = nil
	}

	init(audioURL: URL, author: Author, timestamp: Date = Date()) {
		self.text = nil
		self.author = author
		self.timestamp = timestamp
		self.audioURL = audioURL
	}
	
	init?(dictionary: [String: Any]) {
		guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
			let author = Author(dictionary: authorDictionary),
			let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }

		let text = dictionary[Comment.textKey] as? String

		self.text = text
		self.author = author
		self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
		if let audioURL = dictionary[Comment.audioURLKey] as? String {
			self.audioURL = URL(string: audioURL)
		} else {
			self.audioURL = nil
		}
	}
	
	var dictionaryRepresentation: [String: Any] {
		return [Comment.textKey: text as Any,
				Comment.author: author.dictionaryRepresentation,
				Comment.timestampKey: timestamp.timeIntervalSince1970,
				Comment.audioURLKey: audioURL?.absoluteString as Any]
	}
	
	static func == (lhs: Comment, rhs: Comment) -> Bool {
		return lhs.author == rhs.author &&
			lhs.timestamp == rhs.timestamp
	}
}
