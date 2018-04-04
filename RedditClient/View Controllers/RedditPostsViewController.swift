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
    
    var redditPostViewModels = [RedditPostViewModel]()
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
        if redditPostViewModels.isEmpty {
            activityIndicator.startAnimating()
        }
        redditDataService.getPosts(after: nextPostToLoad) { [weak self] (nextPostToLoad, redditPosts) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                guard let redditPosts = redditPosts else {
                    return
                }
                let redditPostViewModels = redditPosts.map { RedditPostViewModel(redditPost: $0) }
                self?.redditPostViewModels.append(contentsOf: redditPostViewModels)
                self?.nextPostToLoad = nextPostToLoad
                self?.tableView.reloadData()
                self?.isLoadingPosts = false
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditPostViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let redditPostViewModel = redditPostViewModels[indexPath.row]
        let cellIdentifier: String
        
        switch redditPostViewModel.redditPost.type {
        case .image:
            cellIdentifier = postWithImageCellIdentifier
        case .standard:
            cellIdentifier = postCellIdentifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RedditPostTableViewCell
        
        configure(cell, with: redditPostViewModel)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let _ = nextPostToLoad,
            scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height),
            !isLoadingPosts {
            loadRedditPosts()
        }
    }
    
    // MARK: - UI Configuration
    
    func configure(_ cell: RedditPostTableViewCell, with redditPostViewModel: RedditPostViewModel) {
        cell.postDetailLabel.text = redditPostViewModel.detailDisplayText
        cell.postTitleLabel.text = redditPostViewModel.postTitleDisplayText
        cell.commentCountLabel.text = redditPostViewModel.commentsDisplayText
        cell.delegate = self
        
        if let imageUrl = redditPostViewModel.redditPost.imageUrl,
            let image = imageService.fetchImage(forURL: imageUrl) {
            cell.postImageView?.image = image
        }
        else if let imageUrl = redditPostViewModel.redditPost.imageUrl {
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
    }
    
    // MARK: - RedditPostTableViewCellDelegate
    
    func postImageViewTapped(_ sender: RedditPostTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender),
            let imageUrl = redditPostViewModels[indexPath.row].redditPost.imageUrl else { return }
        
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
