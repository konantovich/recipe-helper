//
//  RecipeManager.swift
//  RecipeHelper
//
//  Created by Antbook on 10.02.2022.
//

import Foundation


class RecipeManager {
    
    static let shared = RecipeManager()
    
    var selectedRecipe: Recipe!
    
    var tryAlso: [Recipe]?
    
    
}
