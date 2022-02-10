//
//  ViewController.swift
//  RecipeHelper
//
//  Created by Antbook on 20.01.2022.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    var recipeModel: RecipeSearchModel? = nil
    var filterRecipeModel: RecipeSearchModel?
    
    private var timer: Timer?
    private var sortRecipeInTableView = true
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView = UITableView()
    //var recipes = ["Potato", "Tomato", "Bread", "Milk"]
    
    //когда обращаемся к searchBar, если текст уже введен то переменная будет меняется, если нет то просто выходим и false
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    //когда произошла фильтрация по имени или же нет
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        setupTableView()
        
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
            NetworkService.shared.fetchEdamamRecipes(search: "apple") {[weak self] recipe in
                
                guard let recipe = recipe,
                      let hits = recipe.hits,
                      hits.count > 0 else  {
                          print("nil search")
                          
                          return
                      }
                
                self?.recipeModel = recipe
                
                print(recipe.hits?[0].recipe?.label)
                print(self?.recipeModel?.hits?[0].recipe?.label)
                // print(self?.recipeModel?.hits?.first.recipe?.label)
                self?.tableView.reloadData()
            }
            
        })
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCustomCell.self, forCellReuseIdentifier: "cell")
        
        setupSearchBar()
        
        
    }
    
    func setupSearchBar () {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    
    func setupTableView () {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    
    
}




extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if isFiltering {
            return filterRecipeModel?.hits?.prefix(10).count ?? 0
        }
        guard let recipes = recipeModel else {return 0}
        return (recipes.hits?.prefix(10).count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyCustomCell {
            
            
            
            if isFiltering {
                guard let recipe = filterRecipeModel?.hits?.prefix(10)[indexPath.row] else {return UITableViewCell()}
                
                cell.recipeLabel.text = recipe.recipe?.label
                cell.recipeDescription.text = recipe.recipe?.ingredientLines?.joined(separator: ", ")
                cell.photoRecipe.sd_setImage(with: URL(string: recipe.recipe?.image ?? ""), completed: nil)
                
            } else {
                guard let recipe = recipeModel?.hits?.prefix(10)[indexPath.row] else {return UITableViewCell()}
                
                cell.recipeLabel.text = recipe.recipe?.label
                cell.recipeDescription.text = recipe.recipe?.ingredientLines?.joined(separator: ", ")
                cell.photoRecipe.sd_setImage(with: URL(string: recipe.recipe?.image ?? ""), completed: nil)
                
                // cell.backgroundColor = .blue
                
            }
            return cell
            
        }
        
        // cell.textLabel?.text = recipeModel?.hits?.prefix(10)[indexPath.row].recipe?.label
        
        fatalError("could not dequeueReusableCell")
        
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame:  CGRect(x: 0,y: 0,width: view.frame.width,height: 30))
        //header.backgroundColor = .red
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: Int(header.frame.width), height: Int(header.frame.height)))
        button.setTitle("Sorted by name", for: .normal)
        button.setTitleColor(.green, for: .normal)
        button.addTarget(self, action:  #selector(sortedButtonAction), for: .touchUpInside)
        header.addSubview(button)
        
        
        return header
        
    }
    
    @objc func sortedButtonAction() {
        print("clicked")
        
        if sortRecipeInTableView {
            recipeModel?.hits?.sort() { ($0.recipe?.label)! < ($1.recipe?.label)! }
            sortRecipeInTableView = false
            tableView.reloadData()
        } else {
            recipeModel?.hits?.sort() { ($0.recipe?.label)! > ($1.recipe?.label)! }
            sortRecipeInTableView = true
            tableView.reloadData()
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
}




extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        
        filterRecipeModel?.hits = recipeModel!.hits!.filter{
            $0.recipe!.label!.contains(searchController.searchBar.text!)
            
        }
        
        print(searchController.searchBar.text!)
        print(filterRecipeModel?.hits ?? nil)
//        print(recipeModel?.hits![0].recipe!.label!)
        tableView.reloadData()
        
    }
    
    
    
}











