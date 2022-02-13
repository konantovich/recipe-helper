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
    
    private let viewForTableView = UIView()
    
    private let closeTableView = UIView()
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
    
    private var minimizedTopAnchorForConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorForConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    var openCloseTableView = true
    
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
        dissmisTableViewGesture ()
        
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
    
    
    
    // MARK: - SetupTableView
    func setupTableView () {
        
        viewForTableView.translatesAutoresizingMaskIntoConstraints = false
        closeTableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        //viewForTableView.backgroundColor = .brown
        //closeTableView.backgroundColor = .red
        
        view.addSubview(viewForTableView)
        viewForTableView.addSubview(tableView)
        viewForTableView.addSubview(closeTableView)
       
      //  view.insertSubview(tableView, belowSubview: closeTableView)
        
        maximizedTopAnchorForConstraint = viewForTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
        minimizedTopAnchorForConstraint = viewForTableView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        bottomAnchorConstraint = viewForTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        
        NSLayoutConstraint.activate([
           // viewForTableView.topAnchor.constraint(equalTo: view.topAnchor),
            viewForTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewForTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewForTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        
        maximizedTopAnchorForConstraint.isActive = true
        minimizedTopAnchorForConstraint.isActive = false
        bottomAnchorConstraint.isActive = true
     
       
        
        
        tableView.topAnchor.constraint(equalTo: closeTableView.bottomAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
       
        NSLayoutConstraint.activate([
        closeTableView.heightAnchor.constraint(equalToConstant: 15),
        closeTableView.widthAnchor.constraint(equalToConstant: view.frame.width),
        closeTableView.topAnchor.constraint(equalTo: viewForTableView.topAnchor),
        
        ])
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
            
            //filter  
            
            let randomInt = Int.random(in: indexPath.row..<filterRecipeModel.count)
            
            
            RecipeManager.shared.selectedRecipe = filterRecipeModel[indexPath.row]
            
          
            RecipeManager.shared.tryAlso = [filterRecipeModel[randomInt], filterRecipeModel[randomInt], filterRecipeModel [randomInt]]
            
            present(DetailViewController(), animated: true, completion: nil)
            
        } else {
            //let randomInt = Int.random(in: indexPath.row..<recipeModel.count)
            
            RecipeManager.shared.selectedRecipe = recipeModel[indexPath.row]
            
            
            
            
//            if recipeModel[indexPath.row] == RecipeManager.shared.tryAlso?[indexPath.row] {
//
//
//                RecipeManager.shared.tryAlso?.remove(at: indexPath.row)
//                RecipeManager.shared.tryAlso?.shuffle()
//            }
//
            var tryAlsoArray = recipeModel.filter { $0 != recipeModel[indexPath.row] }
            tryAlsoArray.shuffle()
            
            let detailViewController = DetailViewController()
            detailViewController.tryAlso = tryAlsoArray
            
            
            present(detailViewController, animated: true, completion: nil)
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
           // tableView.reloadData()
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
            
            
          
        
    }
}
}




extension ViewController {
    
    func dissmisTableViewGesture () {
        
        
        closeTableView.backgroundColor = .lightGray
        let image = UIImage(systemName: "square.and.arrow.down")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: (375 - 130) / 2 , y: 0, width: 130, height: 10)
      
        closeTableView.addSubview(imageView)
       
        
       // closeTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMinMax)))//работает по касанию
        closeTableView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
      
     
       
    }
    
    @objc func handleTapMinMax () {
        print("Tapped min/max")
       
        if openCloseTableView {
            minimizeTableView()
            openCloseTableView = false
        } else {
            maximizeTableView()
            openCloseTableView = true
        }
    }
    
    
    @objc func handlePan (gesture: UIPanGestureRecognizer) {
        //print("Tapping")
        
        switch gesture.state { //.state состояние
        case .began:
            print("нажали")
            
           // handleDissmisPan (gesture: gesture)
            
        case .changed:
            //print("тянем координаты \(gesture.translation(in: self.viewForTableView))")
            
            handlePanChange (gesture: gesture)
            
        case .ended:
            print("отпустили зажатие на координатах \(gesture.translation(in: self.viewForTableView))")
            
            handlePanEnded (gesture: gesture)
            
        @unknown default:
            print("unknown default gesture")
        }
        
    }

    
    
    private func handlePanChange (gesture: UIPanGestureRecognizer) {
        //получаем координаты
        let translation = gesture.translation(in: self.viewForTableView)
        //логика что бы наш контроллер двигался за движением пальца (либо на верх либо вниз, по Y)
        viewForTableView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        //уменьшаем альфу в зависимости от положения нашего мини трек вью
        
        
        let newAlpha = 2 + -translation.y / 200
       
       // self.tableView.alpha = newAlpha > 0 ? 0 : newAlpha
        //также присваиваем альфу нашему основному трек вью в зависимости от положения translation.y
        self.tableView.alpha = newAlpha
       // print(-translation.y / 200)
    }
    
   
    private func handlePanEnded (gesture: UIPanGestureRecognizer) {
       
        //get coordinate and speed gesture
        let translation = gesture.translation(in: self.viewForTableView)
        let speed = gesture.velocity(in: self.viewForTableView)//получам/фиксируем скорость
       
        //логика что бы наш контроллер двигался за движением пальца (либо на верх либо вниз, по Y)
        viewForTableView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.viewForTableView.transform = .identity //изначальное состояние (иначе все будет съезжать)
            if -translation.y > -200  { //если подняли мини плеер выше 200 поинтов от начального состояния и если скорость выше чем -500
                self.maximizeTableView()
               
               
            } else {
                self.minimizeTableView()
              
            }
        }, completion: nil) //completion: делает блок кода по завершению анимации
        
        
        
        print(-translation.y, speed.y )  //-translation.y / 200
        
    }
    
    
    func maximizeTableView() {
        print("maximizeTrackDetailsController")
        
        
        maximizedTopAnchorForConstraint.isActive = true
        
        minimizedTopAnchorForConstraint.isActive = false
        
        
        maximizedTopAnchorForConstraint.constant = 0
        bottomAnchorConstraint.constant =  0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()//обновляет каждую милисекунду(иначе будет каждую сек и мы не увидим)
                       // self.tabBar.alpha = 0//прячем таббар
                     //   self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
                       // self.viewForTableView.miniTrackView.alpha = 0
                        self.tableView.alpha = 1
        },
                       completion: nil)
    
    }
    
    func minimizeTableView() {
        
        maximizedTopAnchorForConstraint.isActive = false
        bottomAnchorConstraint.constant = 120
        minimizedTopAnchorForConstraint.isActive = true
        
       // minimizedTopAnchorForConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()//обновляет каждую милисекунду(иначе будет каждую сек и мы не увидим)
                       
                        self.tableView.alpha = 0
           
            
        },
                       completion: nil)
    }
    
    
}
