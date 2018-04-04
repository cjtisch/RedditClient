//
//  RedditDataService.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import Foundation

class RedditDataService {
    private let urlSession = URLSession(configuration: .default)
    private let baseUrl = "https://www.reddit.com/r/popular/top/.json?"
    
    func getPosts(after: String? = nil, completion: @escaping (String?, [RedditPost]?) -> Void) {
        var completeUrl = baseUrl
        
        if let after = after {
            completeUrl += "after=\(after)"
        }
        guard let url = URL(string: completeUrl) else {
            completion(nil, nil)
            return
        }
        
        let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonObject as? [String: Any],
                error == nil,
                response.statusCode == 200 else {
                    completion(nil, nil)
                    return
            }
            let redditPostResponse = RedditPostResponse(json: json)
            completion(redditPostResponse?.after, redditPostResponse?.posts)
        }
        
        dataTask.resume()
    }
}

fileprivate struct RedditPostResponse {
    var after: String?
    var posts: [RedditPost]?
    
    init?(json: [String: Any]) {
        guard let dataJson = json["data"] as? [String: Any],
            let childrenJson = dataJson["children"] as? [[String: Any]] else { return nil }
        
        self.after = dataJson["after"] as? String
        
        var redditPosts = [RedditPost]()
        
        for childJson in childrenJson {
            guard let childDataJson = childJson["data"] as? [String: Any] else { continue }
            
            if let redditPost = RedditPost(json: childDataJson) {
                redditPosts.append(redditPost)
            }
        }
        posts = redditPosts
    }
}
