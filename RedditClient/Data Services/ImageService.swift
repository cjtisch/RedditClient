//
//  ImageService.swift
//  RedditClient
//
//  Created by Tischuk, Christopher on 4/4/18.
//  Copyright © 2018 Tischuk, Christopher. All rights reserved.
//

import UIKit

class ImageService {
    static let sharedInstance = ImageService()
    private let urlSession = URLSession(configuration: .default)
    private var imageCache = NSCache<NSString, UIImage>()
    
    private init() { }
    
    func fetchImage(forURL url: String) -> UIImage? {
        return imageCache.object(forKey: url as NSString)
    }
    
    func downloadImage(forURL url: String, completion: @escaping (UIImage?) -> Void) {
        if let image = fetchImage(forURL: url) {
            completion(image)
            return
        }
        
        guard let imageURL = URL(string: url) else {
            completion(nil)
            return
        }
        
        let dataTask = urlSession.dataTask(with: imageURL) { [weak self] (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                let image = UIImage(data: data),
                error == nil,
                response.statusCode == 200 else {
                    completion(nil)
                    return
            }
            self?.imageCache.setObject(image, forKey: url as NSString)
            completion(image)
        }
        
        dataTask.resume()
    }
}
