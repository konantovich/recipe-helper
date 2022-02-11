//
//  DetailViewController.swift
//  RecipeHelper
//
//  Created by Antbook on 10.02.2022.
//

import Foundation
import UIKit
import SDWebImage


class DetailViewController: UIViewController {
    
    var selectedRecipeModel: Recipe?
    
    var tryAlso: [Recipe]?
    
    var collectionView: UICollectionView!
    // var collectionViewData = [UIColor.red, UIColor.green, UIColor.blue]
    var viewForCollectionView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var photoRecipe: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "square.and.arrow.up")
        imgView.contentMode = .scaleAspectFit
        imgView.layer.cornerRadius = 10
        imgView.layer.masksToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
       // scroll.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scroll.backgroundColor = .red
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    
    
    lazy var recipeLabel : UILabel = {
        let label = UILabel()
        label.text = " Label recipe "
        label.textAlignment = .left
        label.font = UIFont(name: label.font.fontName, size: 20)
        label.numberOfLines = 2
        //…
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var recipeDescription : UILabel = {
        let label = UILabel()
        label.text = "description recipe description recipe description recipe description recipe description recipe description recipe description recipe description recipe "
        label.numberOfLines = 8
        label.font = UIFont(name: label.font.fontName, size: 12)
        
        //…
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var instructionDescription : UITextView = {
        let textView = UITextView()
        
        textView.textAlignment = .left
        textView.text = "Hello World with https://google.com"
        textView.font = UIFont(name: UILabel().font.fontName, size: 12)
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
        textView.backgroundColor = .none
        
        
        //…
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    lazy var tryAlsoLabel : UILabel = {
        let label = UILabel()
        label.text = " Try also "
        
        label.numberOfLines = 1
        //…
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.applyGradients(cornerRadius: 0, startColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), endColor: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))
        
        
        selectedRecipeModel = RecipeManager.shared.selectedRecipe
        
        tryAlso = RecipeManager.shared.tryAlso
        
        
//        swipeTappedOnPhotoRecipe ()
        
        
        let imagesFromUrl = [selectedRecipeModel?.images?.large?.url ?? "", selectedRecipeModel?.images?.regular?.url ?? "", selectedRecipeModel?.images?.small?.url ?? ""]

        for i in 0..<imagesFromUrl.count {
            let imagesForSwipe = RecipeManager.shared.getImageFromUrl(urlString: imagesFromUrl)
            let imageView = imagesForSwipe[i]
            
          //  let xPosition = UIScreen.main.bounds.width * CGFloat(i)
            imageView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
             imageView.contentMode = .scaleAspectFit

           // scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
             scrollView.addSubview(imageView)
             scrollView.delegate = self
        }
        
        
        
        // view.backgroundColor = .white
        viewForCollectionView.backgroundColor = .none
        
        //        recipeLabel.backgroundColor = .red
        //        recipeDescription.backgroundColor = .blue
        //        instructionDescription.backgroundColor = .green
        
        setupCollectionView()
        
        reloadData()
        setupConstraint()
        
        
        self.collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        
        
        
        
        guard let recipe = selectedRecipeModel else {return}
        
        self.photoRecipe.sd_setImage(with: URL(string: recipe.image ?? ""), completed: nil)
        self.recipeLabel.text = recipe.label
        self.recipeDescription.text = recipe.ingredientLines?.joined(separator: ", ")
        self.instructionDescription.text = "See a full recipe: \(URL(string: recipe.url ?? "")!)"
        
        print("selectedRecipeModel", recipe)
        
        
        
    }
    
    
//    func swipeTappedOnPhotoRecipe () {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handlePhotoRecipeTap(_:)))
//        photoRecipe.addGestureRecognizer(tap)
//        photoRecipe.isUserInteractionEnabled = true
//    }
//
//    @objc func handlePhotoRecipeTap(_ sender: UITapGestureRecognizer? = nil) {
//        // handling code
//        print("tapped on photoRecipe", sender)
//    }
    
    private func reloadData () {
        
        
        
        view.addSubview(scrollView)
        view.addSubview(recipeLabel)
        view.addSubview(recipeDescription)
        view.addSubview(instructionDescription)
        view.addSubview(viewForCollectionView)
        view.addSubview(tryAlsoLabel)
//        photoRecipe.addSubview(scrollView)
        
    }
    
    
    
    
    private func setupCollectionView () {
        
        // create a layout to be used
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        // make sure that there is a slightly larger gap at the top of each row
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        // set a standard item size of 60 * 60
        layout.itemSize = CGSize(width: 100, height: 100)
        // the layout scrolls horizontally
        layout.scrollDirection = .horizontal
        // set the frame and layout
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        // set the dataSource
        self.collectionView.dataSource = self
        // set the delegate
        self.collectionView.delegate = self
        // bounce at the bottom of the collection view
        self.collectionView.alwaysBounceVertical = true
        // set the background to be white
        self.collectionView.backgroundColor = .none
        
        self.viewForCollectionView = collectionView
        
        
        
    }
    
    
    
    
    private func setupConstraint () {
        
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalToConstant: 180),
            scrollView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        NSLayoutConstraint.activate([
            
            recipeLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 40),
            recipeLabel.leadingAnchor.constraint(equalTo: viewForCollectionView.leadingAnchor, constant: 0),
            recipeLabel.heightAnchor.constraint(equalToConstant: 50),
            recipeLabel.widthAnchor.constraint(equalToConstant: 300),
            
            
            
        ])
        NSLayoutConstraint.activate([
            
            recipeDescription.topAnchor.constraint(equalTo: recipeLabel.bottomAnchor, constant: 30),
            recipeDescription.leadingAnchor.constraint(equalTo: viewForCollectionView.leadingAnchor, constant: 0),
            recipeDescription.heightAnchor.constraint(equalToConstant: 80),
            recipeDescription.widthAnchor.constraint(equalToConstant: view.center.x + 80),
            
        ])
        
        
        NSLayoutConstraint.activate([
            
            instructionDescription.topAnchor.constraint(equalTo: recipeDescription.bottomAnchor, constant: 10),
            instructionDescription.leadingAnchor.constraint(equalTo: viewForCollectionView.leadingAnchor, constant: 0),
            instructionDescription.heightAnchor.constraint(equalToConstant: 40),
            instructionDescription.widthAnchor.constraint(equalToConstant: view.center.x + 80),
            
        ])
        
        NSLayoutConstraint.activate([
            tryAlsoLabel.bottomAnchor.constraint(equalTo: viewForCollectionView.topAnchor, constant: 10),
            tryAlsoLabel.leadingAnchor.constraint(equalTo: viewForCollectionView.leadingAnchor, constant: 0),
            tryAlsoLabel.heightAnchor.constraint(equalToConstant: 40),
            tryAlsoLabel.widthAnchor.constraint(equalToConstant: view.center.x + 80),
        ])
        
        NSLayoutConstraint.activate([
            viewForCollectionView.topAnchor.constraint(equalTo: instructionDescription.bottomAnchor, constant: 80),
            viewForCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewForCollectionView.heightAnchor.constraint(equalToConstant: 100),
            viewForCollectionView.widthAnchor.constraint(equalToConstant: view.center.x + 150),
        ])
        
    }
    
    
}



extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // dequeue the standard cell
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell {
            //    let data = self.collectionViewData[indexPath.item]
            guard let tryAlso = tryAlso?[indexPath.row] else {
                fatalError("Unable to dequeue subclassed cell")
            }
            cell.setupCell(recipe: tryAlso )
            
            
            return cell
        } else {
            fatalError("Unable to dequeue subclassed cell")
        }
        
    }
    
    // if the user clicks on a cell, display a message
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        
        
        guard let tryAlso = tryAlso?[indexPath.row] else {
            fatalError("Unable to dequeue subclassed cell")
        }
        
        guard let url = URL(string: tryAlso.url ?? "") else { return }
        UIApplication.shared.open(url)
        
        
    }
    
    
    
}







