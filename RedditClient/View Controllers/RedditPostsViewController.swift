//
//  RedditPostsViewController.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

class RedditPostsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var redditPosts = [RedditPost]()
    private var nextPostToLoad: String?
    private var isLoadingPosts = false
    private let postWithImageCellIdentifier = "postWithImageCell"
    private let postCellIdentifier = "postCell"
    private lazy var redditDataService = RedditDataService()
    private lazy var imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRedditPosts()
    }
    
    // MARK: - Remote Data
    
    private func loadRedditPosts() {
        isLoadingPosts = true
        activityIndicator.startAnimating()
        redditDataService.getPosts() { [weak self] (nextPostToLoad, redditPosts) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                guard let redditPosts = redditPosts else {
                    return
                }
                self?.redditPosts = redditPosts
                self?.nextPostToLoad = nextPostToLoad
                self?.tableView.reloadData()
                self?.isLoadingPosts = false
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let redditPost = redditPosts[indexPath.row]
        let cellIdentifier: String
        
        switch redditPost.type {
        case .image:
            cellIdentifier = postWithImageCellIdentifier
        case .standard:
            cellIdentifier = postCellIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RedditPostTableViewCell
        
        var detailText = dateString(from: redditPost.dateCreated)
        if let authorName = redditPost.author {
            detailText += "∙ \(authorName)"
        }
        cell.postDetailLabel.text = detailText
        cell.postTitleLabel.text = redditPost.title
        cell.commentCountLabel.text = "\(redditPost.commentsCount) Comments"
        
        if let imageUrl = redditPost.imageUrl,
            let image = imageService.fetchImage(forURL: imageUrl) {
            cell.postImageView?.image = image
        }
        else if let imageUrl = redditPost.imageUrl {
            cell.imageUrl = imageUrl
            imageService.downloadImage(forURL: imageUrl, completion: { (image) in
                if let image = image,
                    cell.imageUrl == imageUrl {
                    DispatchQueue.main.async {
                        cell.postImageView?.image = image
                    }
                }
            })
        }
        
        return cell
    }
    
    // MARK: - UI Configuration
    
    private func dateString(from date: Date) -> String {
        let dateDifference = date.timeIntervalSinceNow
        let hours = Int(dateDifference)/3600
        let minutes = Int(dateDifference)/60
        
        if hours == 0 {
            return "\(abs(minutes)) minutes ago"
        }
        return "\(abs(hours)) hours ago"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
