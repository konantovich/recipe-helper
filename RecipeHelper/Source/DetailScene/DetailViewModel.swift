//
//  RecipeManager.swift
//  RecipeHelper
//
//  Created by Antbook on 10.02.2022.
//

import Foundation
import UIKit
import SDWebImage

class DetailViewModel {

    func getImageFromUrl (urlString: [String]) -> [UIImageView] {
        
        let image = UIImageView()
        var urlImage = [UIImageView]()
        
        urlString.forEach { url in
            image.sd_setImage(with: URL(string: url), completed: nil)
            urlImage.append(image)
        }
        return urlImage
    }
}



