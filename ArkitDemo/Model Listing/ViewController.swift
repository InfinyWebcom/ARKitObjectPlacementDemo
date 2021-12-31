//
//  ViewController.swift
//  ArkitDemo
//
//  Created by Alexander John on 26/10/21.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var designCollectionView: UICollectionView!
    
    //MARK: - Class properties
    #warning("make sure your model name and image names are the same")
    let images = [UIImage(named: "candle"),
                  UIImage(named: "lamp"),
                  UIImage(named: "toy_drummer"),
                  UIImage(named: "Wall_Clock"),
                  UIImage(named: "CouchSofa_Set"),
                  UIImage(named: "Forteresse_Royale_de_Najac"),
                  UIImage(named: "Sponza"),
                  UIImage(named: "Lowpoly_tree_sample")]
    
    var modelNames = ["candle.scn",
                      "lamp.scn",
                      "toy_drummer.usdz",
                      "Wall_Clock.usdz",
                      "CouchSofa_Set.usdz",
                      "Forteresse_Royale_de_Najac.usdz",
                      "Sponza.usdz",
                      "Lowpoly_tree_sample.dae"]
    
    //MARK: - ViewController Events
    override func viewDidLoad() {
        super.viewDidLoad()
        designCollectionView.delegate = self
        designCollectionView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        let layout = UICollectionViewFlowLayout()
        let size = ((self.view.frame.width - 10)/2)
        layout.itemSize = CGSize(width: size, height: size)
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        designCollectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath as IndexPath) as! CustomCollectionViewCell
        cell.designPreviewView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfSections section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = ((self.view.frame.width - 10)/2)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aRDesignViewer = storyboard.instantiateViewController(withIdentifier: "ARDesignViewer") as! ARDesignViewer
        aRDesignViewer.modelName = modelNames[indexPath.row]
        if indexPath.row == 3{
            aRDesignViewer.planeType = [.vertical]
        }else{
            aRDesignViewer.planeType = [.horizontal]
        }
        self.navigationController?.pushViewController(aRDesignViewer, animated: true)
    }
}
