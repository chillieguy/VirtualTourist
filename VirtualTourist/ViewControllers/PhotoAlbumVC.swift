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
        
        
//        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
//        let predicate = NSPredicate(format: "pin == %@", pin)
//        fetchRequest.predicate = predicate
//
//        if let result = try? dataController.viewContext.fetch(fetchRequest) {
//            pin = result[0]
//            print(pin)
//        }
        
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

extension PhotoAlbumVC: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.green
        
        return cell
    }
    
    
}


