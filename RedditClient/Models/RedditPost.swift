//
//  RedditPost.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import Foundation

enum postType {
    case image
    case standard
}

struct RedditPost {
    var title: String
    var author: String?
    var dateCreated: Date
    var commentsCount: Int
    var imageUrl: String?
    var type: postType
    
    init?(json: [String: Any]) {
        guard let title = json["title"] as? String,
            let dateValue = json["created_utc"] as? Double,
            let commentsCount = json["num_comments"] as? Int else { return nil }
        
        self.title = title
        self.author = json["author"] as? String
        self.dateCreated = Date(timeIntervalSince1970: dateValue)
        self.commentsCount = commentsCount
        if let imageUrl = json["thumbnail"] as? String,
            imageUrl.lowercased() != "default",
            imageUrl.lowercased() != "self" {
            self.imageUrl = imageUrl
            self.type = .image
        }
        else {
            self.type = .standard
        }
    }
}
