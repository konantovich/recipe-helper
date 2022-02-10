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
    
    var collectionView: UICollectionView!
    var collectionViewData = [UIColor.red, UIColor.green, UIColor.blue]
    var viewForCollectionView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var photoRecipe: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(systemName: "square.and.arrow.up")
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy var recipeLabel : UILabel = {
        let label = UILabel()
        label.text = " Label recipe "
        
        label.numberOfLines = 1
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
        
        textView.textAlignment = NSTextAlignment.justified
        textView.text = "Hello World with https://google.com"
        textView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        textView.isSelectable = true
        textView.isEditable = false
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = .link
        
        
        //…
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedRecipeModel = RecipeManager.shared.selectedRecipe
        
        
        view.backgroundColor = .white
        viewForCollectionView.backgroundColor = .yellow
        
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
        self.instructionDescription.text = "see a full recipe: \(URL(string: recipe.url ?? "")!)"
        
        print("selectedRecipeModel", recipe)
        
        
        
    }
    
    
    private func reloadData () {
        
        
        
        view.addSubview(photoRecipe)
        view.addSubview(recipeLabel)
        view.addSubview(recipeDescription)
        view.addSubview(instructionDescription)
       view.addSubview(viewForCollectionView)
      
        
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
        self.collectionView.backgroundColor = .white
        
        self.viewForCollectionView = collectionView
        
      
        
    }
    
    
    
    
    private func setupConstraint () {
        
        
        
        NSLayoutConstraint.activate([
            photoRecipe.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            photoRecipe.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoRecipe.widthAnchor.constraint(equalToConstant: 150),
            photoRecipe.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        NSLayoutConstraint.activate([
            
            recipeLabel.topAnchor.constraint(equalTo: photoRecipe.bottomAnchor, constant: 40),
            recipeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipeLabel.heightAnchor.constraint(equalToConstant: 50),
            recipeLabel.widthAnchor.constraint(equalToConstant: 300),
            
            
            
        ])
        NSLayoutConstraint.activate([
            
            recipeDescription.topAnchor.constraint(equalTo: recipeLabel.bottomAnchor, constant: 40),
            recipeDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recipeDescription.heightAnchor.constraint(equalToConstant: 80),
            recipeDescription.widthAnchor.constraint(equalToConstant: view.center.x + 80),
            
        ])
        
        
        NSLayoutConstraint.activate([
            
            instructionDescription.topAnchor.constraint(equalTo: recipeDescription.bottomAnchor, constant: 40),
            instructionDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionDescription.heightAnchor.constraint(equalToConstant: 40),
            instructionDescription.widthAnchor.constraint(equalToConstant: view.center.x + 80),
            
        ])
        
        NSLayoutConstraint.activate([
            viewForCollectionView.topAnchor.constraint(equalTo: instructionDescription.bottomAnchor, constant: 40),
            viewForCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            viewForCollectionView.heightAnchor.constraint(equalToConstant: 100),
            viewForCollectionView.widthAnchor.constraint(equalToConstant: view.center.x + 150),
        ])
        
    }
    
    
}



extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // dequeue the standard cell
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell {
        let data = self.collectionViewData[indexPath.item]
        cell.setupCell(colour: data)
        return cell
        } else {
            fatalError("Unable to dequeue subclassed cell")
        }
        
    }
    
    // if the user clicks on a cell, display a message
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
    }
}







