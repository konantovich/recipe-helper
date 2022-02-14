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
    
    let viewModel = ViewModel()
    
    private var timer: Timer?
    private var sortRecipeInTableView = true
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView = UITableView()
    private let viewForTableView = UIView()
    private let closeTableView = UIView()
    
    //когда обращаемся к searchBar, если текст уже введен
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
    
    var isApiModeEnable = true
    
    private var minimizedTopAnchorForConstraint: NSLayoutConstraint!
    private var maximizedTopAnchorForConstraint: NSLayoutConstraint!
    private var closeTableViewTopAnchorConstraint: NSLayoutConstraint!
    
    var openCloseTableView = true
    
    
    lazy var loadingLabel : UILabel = {
        let label = UILabel()
        label.text = " Loading... "
        label.frame = CGRect(x: view.center.x - 60, y: view.center.y - 60, width: 120, height: 120)
        label.textAlignment = .center
        label.font = UIFont(name: label.font.fontName, size: 23)
        label.numberOfLines = 1
        return label
    }()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let startColor = #colorLiteral(red: 0.7110412717, green: 0.7906122804, blue: 0.8905088305, alpha: 1), endColor = #colorLiteral(red: 0.9450980392, green: 0.8509803922, blue: 0.9568627451, alpha: 1)
        view.applyGradients(cornerRadius: 0, startColor: startColor, endColor: endColor)
        
        setupTableView()
        dissmisTableViewGesture ()
        setupSearchBar()
        
        view.addSubview(loadingLabel)
        
        requestSearchData(searchText: "Apple")
    }
    //MARK: - Network Request
    func requestSearchData (searchText: String) {
        
        viewModel.requestSearchData(searchText: searchText) { recipe in
            self.recipeModel = (recipe.hits?.prefix(10).compactMap { $0.recipe }) ?? []
            self.tableView.reloadData()
            self.loadingLabel.text = ""
        }
    }
    
    // MARK: - SetupSearchBar
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
        
        tableView.backgroundColor = .none
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MyCustomCell.self, forCellReuseIdentifier: "cell")
        
        viewForTableView.translatesAutoresizingMaskIntoConstraints = false
        closeTableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        //viewForTableView.backgroundColor = .brown
        //closeTableView.backgroundColor = .red
        
        view.addSubview(viewForTableView)
        viewForTableView.addSubview(tableView)
        viewForTableView.addSubview(closeTableView)
        //  view.insertSubview(tableView, belowSubview: closeTableView)
        
        maximizedTopAnchorForConstraint = viewForTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        minimizedTopAnchorForConstraint = viewForTableView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        maximizedTopAnchorForConstraint.isActive = true
        minimizedTopAnchorForConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            // viewForTableView.topAnchor.constraint(equalTo: view.topAnchor),
            viewForTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewForTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewForTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.topAnchor.constraint(equalTo: closeTableView.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: viewForTableView.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: viewForTableView.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: viewForTableView.rightAnchor).isActive = true
        
        NSLayoutConstraint.activate([
            closeTableView.heightAnchor.constraint(equalToConstant: 15),
            closeTableView.widthAnchor.constraint(equalToConstant: view.frame.width),
        ])
        closeTableViewTopAnchorConstraint = closeTableView.topAnchor.constraint(equalTo: viewForTableView.topAnchor)
        closeTableViewTopAnchorConstraint.constant = 140
        closeTableViewTopAnchorConstraint.isActive = true
    }
}
//MARK: - UITableViewDelegate, UITableViewDataSource
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
        fatalError("could not dequeueReusableCell")
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath)
        
        if isFiltering {
            var tryAlsoArray = filterRecipeModel.filter { $0 != filterRecipeModel[indexPath.row] }
            tryAlsoArray.shuffle()
            
            let detailViewController = DetailViewController()
            detailViewController.tryAlso = tryAlsoArray
            
            present(detailViewController, animated: true, completion: nil)
        } else {
            
            let detailViewController = DetailViewController()
            detailViewController.selectedRecipe = recipeModel[indexPath.row]
            //            if recipeModel[indexPath.row] == RecipeManager.shared.tryAlso?[indexPath.row] {
            //                RecipeManager.shared.tryAlso?.remove(at: indexPath.row)
            //                RecipeManager.shared.tryAlso?.shuffle()
            //            }
            //
            var tryAlsoArray = recipeModel.filter { $0 != recipeModel[indexPath.row] }
            tryAlsoArray.shuffle()
            
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
//MARK: - UISearchResultsUpdating
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
//MARK: - GestureRecognizer (open/close tableView)
extension ViewController {
    
    func dissmisTableViewGesture () {
        closeTableView.backgroundColor = .lightGray
        let image = UIImage(systemName: "square.and.arrow.down")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: (375 - 130) / 2 , y: 0, width: 130, height: 10)
        
        closeTableView.addSubview(imageView)
        
        // closeTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMinMax)))
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
        //get coordinate
        let translation = gesture.translation(in: self.viewForTableView)
        //логика что бы наш контроллер двигался за движением пальца (по Y)
        viewForTableView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        //уменьшаем альфу в зависимости от положения нашего viewForTableView
        let newAlpha = 2 + -translation.y / 200
        self.tableView.alpha = newAlpha
        print(newAlpha)
        print(self.tableView.alpha)
    }
    
    private func handlePanEnded (gesture: UIPanGestureRecognizer) {
        //get coordinate and speed gesture
        let translation = gesture.translation(in: self.viewForTableView)
        let speed = gesture.velocity(in: self.viewForTableView)//получам/фиксируем скорость
        
        //логика что бы наш контроллер двигался за движением пальца (либо на верх либо вниз, по Y)
        viewForTableView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        if -translation.y > -200 && speed.y < -500  { //если подняли 200 поинтов от начального состояния и если скорость ниже чем -500
            self.maximizeTableView()
        } else {
            self.minimizeTableView()
        }
        print(-translation.y, speed.y )  //-translation.y / 200
    }
    
    func maximizeTableView() {
        print("maximizeTrackDetailsController")
        maximizedTopAnchorForConstraint.isActive = true
        minimizedTopAnchorForConstraint.isActive = false
        
        closeTableViewTopAnchorConstraint.constant = 140
        maximizedTopAnchorForConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()//обновляет каждую милисекунду(иначе не увидим)
            self.viewForTableView.transform = .identity //изначальное состояние (иначе все будет съезжать)
            self.tableView.alpha = 1
        },
                       completion: nil)
    }
    
    func minimizeTableView() {
        
        maximizedTopAnchorForConstraint.isActive = false
        minimizedTopAnchorForConstraint.isActive = true
        closeTableViewTopAnchorConstraint.constant = 0
        // minimizedTopAnchorForConstraint.constant = 0
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1,
                       options: .curveEaseOut,
                       animations: {
            self.view.layoutIfNeeded()//обновляет каждую милисекунду(иначе мы не увидим)
            self.viewForTableView.transform = .identity //изначальное состояние (иначе все будет съезжать)
            self.tableView.alpha = 0
        },
                       completion: nil)
    }
}
