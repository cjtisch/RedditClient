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
    private let imageRestorationKey = "imageUrl"
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
            imageService.downloadImage(forURL: imageUrl) { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveImage(_ sender: UIBarButtonItem) {
        guard let image = imageView.image else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        if error != nil {
            let alertController = UIAlertController(title: "Error", message: "Could not save photo at this time.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        else {
            let alertController = UIAlertController(title: "Saved!", message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        if let imageUrl = imageUrl {
            coder.encode(imageUrl, forKey: imageRestorationKey)
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        imageUrl = coder.decodeObject(forKey: imageRestorationKey) as? String
        
        super.decodeRestorableState(with: coder)
    }
}
