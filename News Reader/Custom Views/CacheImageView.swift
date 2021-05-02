//
//  CacheImageView.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 28/04/21.
//

import UIKit

let imageChace = NSCache<NSString, UIImage>()

class CacheImageView: UIImageView {
    
    var imageUrlString: String?
    
    func downloadImage(from link: String) {
        
        self.imageUrlString = link
        
        if let imageFromCache = imageChace.object(forKey: link as NSString) {
            
            self.image = imageFromCache
            return
        }
        
        self.image = UIImage(named: "placeholder_image")
        
        Webservice().downloadImage(with: link) { (result) in
            
            switch result {
            case .success(let image):
                imageChace.setObject(image, forKey: link as NSString)
                if self.imageUrlString == link {
                    self.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
