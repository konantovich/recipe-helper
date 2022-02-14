//
//  ViewModel.swift
//  RecipeHelper
//
//  Created by Antbook on 13.02.2022.
//

import Foundation
import UIKit
import SDWebImage


class ViewModel {
    
    private var timer: Timer?
    
    let networkService = NetworkService()
    
    //MARK: - Network Request
    func requestSearchData (searchText: String, completion: @escaping (RecipeSearchModel) -> () ) -> Void  {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
            self.networkService.fetchEdamamRecipes(search: searchText) { [weak self] recipe in
                
                guard let recipe = recipe,
                      let hits = recipe.hits,
                      hits.count > 0 else  {
                          print("nil search")
                          return
                      }
//                recipe.hits?.prefix(10).compactMap { $0.recipe }
                
                completion(recipe)
               
            }
        })
    }
    
    
    
    
}
