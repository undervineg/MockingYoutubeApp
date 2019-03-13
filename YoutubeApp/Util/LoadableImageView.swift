//
//  LoadableImageView.swift
//  YoutubeApp
//
//  Created by 심승민 on 10/03/2019.
//  Copyright © 2019 심승민. All rights reserved.
//

import UIKit

final class LoadableImageView: UIImageView {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .gray)
        i.translatesAutoresizingMaskIntoConstraints = false
        i.startAnimating()
        return i
    }()
    
    let imageCache = NSCache<NSString, UIImage>()
    
    var imageUrlString: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor(white: 0.9, alpha: 0.7)
        
        addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func loadImage(urlString: String) {
        imageUrlString = urlString
        
        guard let url = URL(string: urlString) else { return }
        image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respones, error) in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                guard let imageToCache = UIImage(data: data!) else { return }
                
                if self.imageUrlString == urlString {
                    self.activityIndicatorView.stopAnimating()
                    self.image = imageToCache
                }
                
                self.imageCache.setObject(imageToCache, forKey: urlString as NSString)
            }
            
        }).resume()
    }
    
}
