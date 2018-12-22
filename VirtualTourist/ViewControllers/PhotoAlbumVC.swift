//
//  PhotoAlbumVC
//  VirtualTourist
//
//  Created by Chuck Underwood on 10/24/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController {

    var coord = CLLocationCoordinate2D()
    
    var dataController: DataController!
    
    var pin: Pin!
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollection.delegate = self
        photoCollection.dataSource = self
        
        print(pin)
        let fp = FlickrProvider()
        fp.getImagesFromFlickr { (urls) -> () in
            print(urls)
        }
        
        setupMapView()
    }
    
    func setupMapView() {
        var region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
        region.center = coord
        map.setRegion(region, animated: true)
        map.isZoomEnabled = false
        map.isScrollEnabled = false
        map.isZoomEnabled = false
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord
        map.addAnnotation(annotation)
        
        
        map.delegate = self
        photoCollection.delegate = self
        photoCollection.dataSource = self
    }
    

}

extension PhotoAlbumVC: MKMapViewDelegate {
    
}

extension PhotoAlbumVC: UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoCollectionViewCellImage.image = #imageLiteral(resourceName: "loading")
        cell.backgroundColor = UIColor.blue
        cell.photoCollectionViewCellActivityIndicator.isHidden = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: photoCollection.bounds.size.width / 3, height: photoCollection.bounds.size.width / 3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}


