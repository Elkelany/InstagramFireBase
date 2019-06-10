//
//  CustomImageView.swift
//  InstagramFireBase
//
//  Created by macOS on 3/18/19.
//  Copyright © 2019 macOS. All rights reserved.
//

import UIKit

var imageCashe = [String: UIImage]()

class CustomImageView: UIImageView {
    var lastURLUsedToLoadImage: String?
    func loadImage(urlString: String) {
        lastURLUsedToLoadImage = urlString
        self.image = nil
        if let cachedImage = imageCashe[urlString] {
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, respose, error) in
            if let error = error {
                print("Failed to fetch post image:", error)
                return
            }
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            guard let imageData = data else { return }
            let photoImage = UIImage(data: imageData)
            imageCashe[url.absoluteString] = photoImage
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }).resume()
    }
}
