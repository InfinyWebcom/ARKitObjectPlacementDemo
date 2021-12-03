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
        let padding: CGFloat =  15
        let collectionViewSize = designCollectionView.frame.size.width - padding
        let layout = designCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 20
        layout.invalidateLayout()
        return CGSize(width: ((collectionViewSize / 2) - 6), height: ((collectionViewSize / 2) - 6))
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
