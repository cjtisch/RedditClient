//
//  RedditPostViewModel.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import Foundation

struct RedditPostViewModel {
    var redditPost: RedditPost
    
    // MARK: - Computed Display Properties
    
    var detailDisplayText: String {
        var detailText = RedditPostViewModel.dateString(from: redditPost.dateCreated)
        if let authorName = redditPost.author {
            detailText += " ∙ \(authorName)"
        }
        return detailText
    }
    
    var postTitleDisplayText: String {
        return redditPost.title
    }
    
    var commentsDisplayText: String {
        return "\(redditPost.commentsCount) Comments"
    }
    
    static func dateString(from date: Date) -> String {
        let dateDifference = date.timeIntervalSinceNow
        let hours = Int(dateDifference)/3600
        let minutes = Int(dateDifference)/60
        
        if hours == 0 {
            return "\(abs(minutes)) minutes ago"
        }
        return "\(abs(hours)) hours ago"
    }
}
