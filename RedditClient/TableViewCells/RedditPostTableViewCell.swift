//
//  RedditPostTableViewCell.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

protocol RedditPostTableViewCellDelegate: AnyObject {
    func postImageViewTapped(_ sender: RedditPostTableViewCell)
}

class RedditPostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView?
    @IBOutlet weak var postDetailLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var imageUrl = ""
    weak var delegate: RedditPostTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(postImageViewTapped(_:))))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView?.image = nil
        imageUrl = ""
    }

    // MARK: - Actions
    
    @objc func postImageViewTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            delegate?.postImageViewTapped(self)
        }
    }
}
