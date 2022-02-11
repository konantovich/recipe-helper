//
//  ViewController.swift
//  RecipeHelper
//
//  Created by Antbook on 20.01.2022.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    var recipeModel: [Recipe] = []
    var filterRecipeModel: [Recipe] = []
    
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
        if isApiModeEnable == false {
            return false
        } else {
            return searchController.isActive && !searchBarIsEmpty
        }

       
    }
    
    var isApiModeEnable: Bool = true
    
  //  var searchText = "Apple"
 
    
    lazy var loadingLabel : UILabel = {
        let label = UILabel()
        label.text = " Loading... "
        label.frame = CGRect(x: view.center.x - 60, y: view.center.y - 60, width: 120, height: 120)
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 23)
        label.numberOfLines = 1
        //…
      //  label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startColor = #colorLiteral(red: 0.7110412717, green: 0.7906122804, blue: 0.8905088305, alpha: 1), endColor = #colorLiteral(red: 0.9450980392, green: 0.8509803922, blue: 0.9568627451, alpha: 1)
       
        view.applyGradients(cornerRadius: 0, startColor: startColor, endColor: endColor)
        
        tableView.backgroundColor = .none
        setupTableView()
        view.addSubview(loadingLabel)
        
       requestSearchData(searchText: "Apple")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCustomCell.self, forCellReuseIdentifier: "cell")
        
        setupSearchBar()
        
        
    }
    
    func requestSearchData (searchText: String) {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (_) in
            NetworkService.shared.fetchEdamamRecipes(search: searchText) { [weak self] recipe in
                
                guard let recipe = recipe,
                      let hits = recipe.hits,
                      hits.count > 0 else  {
                          print("nil search")
                          
                          return
                      }
                
                self?.recipeModel = (recipe.hits?.prefix(10).compactMap { $0.recipe }) ?? []
                
//                print(recipe.hits?[0].recipe?.label)
//                print(self?.recipeModel?.hits?[0].recipe?.label)
                // print(self?.recipeModel?.hits?.first.recipe?.label)
                self?.tableView.reloadData()
                self?.loadingLabel.text = ""
                
                
            }
            
        })
        
        
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
            return filterRecipeModel.prefix(10).count
        }
        
        return recipeModel.prefix(10).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyCustomCell {
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.8509803922, blue: 0.9568627451, alpha: 1)
            cell.selectedBackgroundView = backgroundView
            
            if isFiltering {
                let recipe = filterRecipeModel.prefix(10)[indexPath.row]
                
                cell.recipeLabel.text = recipe.label
                cell.recipeDescription.text = recipe.ingredientLines?.joined(separator: ", ")
                cell.photoRecipe.sd_setImage(with: URL(string: recipe.image ?? ""), completed: nil)
                
            } else {
                let recipe = recipeModel.prefix(10)[indexPath.row]
                
                cell.recipeLabel.text = recipe.label
                cell.recipeDescription.text = recipe.ingredientLines?.joined(separator: ", ")
                cell.photoRecipe.sd_setImage(with: URL(string: recipe.image ?? ""), completed: nil)
                
                
                
            }
            return cell
            
        }
        
        // cell.textLabel?.text = recipeModel?.hits?.prefix(10)[indexPath.row].recipe?.label
        
        fatalError("could not dequeueReusableCell")
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        
        
        
        if isFiltering {
            
            RecipeManager.shared.selectedRecipe = filterRecipeModel[indexPath.row]
            
            RecipeManager.shared.tryAlso = [filterRecipeModel[indexPath.row + 1], filterRecipeModel[indexPath.row + 2], filterRecipeModel[indexPath.row + 3]]
            
            present(DetailViewController(), animated: true, completion: nil)
            
        } else {
            
            RecipeManager.shared.selectedRecipe = recipeModel[indexPath.row]
            
            RecipeManager.shared.tryAlso = [recipeModel[indexPath.row + 1], recipeModel[indexPath.row + 2], recipeModel[indexPath.row + 3]]
            
            present(DetailViewController(), animated: true, completion: nil)
        }
        
       
        
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = UIView(frame:  CGRect(x: 0,y: 0,width: view.frame.width, height: 30))
       // header.backgroundColor = .gray
        
        let button = UIButton(frame: CGRect(x: 10 , y: 0, width: 175, height: 30))
        
        let apiModeButton = UIButton(frame: CGRect(x: Int(view.frame.width) - 150 , y: 0, width: 125 , height: 30))
        
       // apiModeButton.backgroundColor = .red
        apiModeButton.setTitle("API Mode", for: .normal)
        apiModeButton.setTitleColor( .orange, for: .normal)
        apiModeButton.addTarget(self, action:  #selector(apiModeButtonAction), for: .touchUpInside)
        
        button.setTitle("Sorted by name:", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        button.addTarget(self, action:  #selector(sortedButtonAction), for: .touchUpInside)
        header.addSubview(button)
        header.addSubview(apiModeButton)
        
        
        return header
        
    }
    
    @objc func apiModeButtonAction () {
        print("apiModeButtonAction clicked")
        
        if isApiModeEnable {
            
            print("apiMode Enable")
            isApiModeEnable = false
            tableView.reloadData()
        } else {
            
            print("apiMode Disable")
            isApiModeEnable = true
            tableView.reloadData()
        }
        
    }
    
    @objc func sortedButtonAction() {
        print("sortedButtonAction clicked")
        
        if sortRecipeInTableView {
            recipeModel.sort() { ($0.label)! < ($1.label)! }
            sortRecipeInTableView = false
            tableView.reloadData()
        } else {
            recipeModel.sort() { ($0.label)! > ($1.label)! }
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
        
        print(searchController.searchBar.text ?? "")
        
        if isApiModeEnable {
            
            filterRecipeModel = recipeModel.filter {
                
                $0.label!.contains(searchController.searchBar.text!)
            }
            tableView.reloadData()
        } else {
            
           requestSearchData(searchText: searchController.searchBar.text!)
            
            
           // tableView.reloadData()
        
    }
}
}
