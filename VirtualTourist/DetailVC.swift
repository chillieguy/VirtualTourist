//
//  DetailVC.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 10/24/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit
import MapKit

class DetailVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

}

extension DetailVC: MKMapViewDelegate {
    
}

extension DetailVC: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        cell.backgroundColor = UIColor.green
        
        return cell
    }
    
    
}


