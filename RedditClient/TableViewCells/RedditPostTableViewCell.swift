//
//  RedditPostTableViewCell.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

class RedditPostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView?
    @IBOutlet weak var postDetailLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
