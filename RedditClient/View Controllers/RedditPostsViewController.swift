//
//  RedditPostsViewController.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

class RedditPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RedditPostTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var redditPosts = [RedditPost]()
    private var nextPostToLoad: String?
    private var isLoadingPosts = false
    private let postWithImageCellIdentifier = "postWithImageCell"
    private let postCellIdentifier = "postCell"
    private let imageDetailSegueIdentifier = "imageDetailSegue"
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
    
    private func loadMoreRedditPosts() {
        isLoadingPosts = true
        redditDataService.getPosts(after: nextPostToLoad) { [weak self] (nextPostToLoad, redditPosts) in
            DispatchQueue.main.async {
                guard let redditPosts = redditPosts else {
                    return
                }
                self?.redditPosts.append(contentsOf: redditPosts)
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
            detailText += " ∙ \(authorName)"
        }
        cell.postDetailLabel.text = detailText
        cell.postTitleLabel.text = redditPost.title
        cell.commentCountLabel.text = "\(redditPost.commentsCount) Comments"
        cell.delegate = self
        
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
    
    // MARK: - UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = nextPostToLoad,
            scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height),
            !isLoadingPosts {
            loadMoreRedditPosts()
        }
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
    
    // MARK: - RedditPostTableViewCellDelegate
    
    func postImageViewTapped(_ sender: RedditPostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender),
            let imageUrl = redditPosts[indexPath.row].imageUrl else { return }
        
        performSegue(withIdentifier: imageDetailSegueIdentifier, sender: imageUrl)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let imageUrl = sender as? String,
            let imageDetailViewController = segue.destination as? ImageDetailViewController,
            segue.identifier == imageDetailSegueIdentifier {
            imageDetailViewController.imageUrl = imageUrl
        }
    }
    
}
