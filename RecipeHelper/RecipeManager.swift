//
//  RecipeManager.swift
//  RecipeHelper
//
//  Created by Antbook on 10.02.2022.
//

import Foundation
import UIKit
import SDWebImage

class RecipeManager {
    
    static let shared = RecipeManager()
    
    var selectedRecipe: Recipe!
    
    var tryAlso: [Recipe]?
    
    
    
    func getImageFromUrl (urlString: [String]) -> [UIImageView] {
        
        let image = UIImageView()
        var urlImage = [UIImageView]()
        
        urlString.forEach { url in
            image.sd_setImage(with: URL(string: url), completed: nil)
            urlImage.append(image)
        }
        
        return urlImage
    }
    
    
    
    func getRandomArray(inInt: Int, outInt: Int) -> [Int] {
        return (0..<2).map { _ in .random(in: inInt...outInt) }
    }
    
    func getRandomThreeRandomInt (inInt: Int, outInt: Int, currentInt: Int) -> [Int]? {
        
        let result = [Int]()
        
        let randomInt = Int.random(in: inInt..<outInt)
        
        if randomInt == currentInt {
            
        }
        
        
        return result
        
    }
    
    
}



