//
//  ImageDetailViewController.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

class ImageDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl: String?
    private lazy var imageService = ImageService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadImage()
    }
    
    // MARK: - Remote Data
    
    private func loadImage() {
        guard let imageUrl = imageUrl else { return }
        
        if let image = imageService.fetchImage(forURL: imageUrl) {
            imageView.image = image
        }
        else {
            imageService.downloadImage(forURL: imageUrl, completion: { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            })
        }
    }
}
