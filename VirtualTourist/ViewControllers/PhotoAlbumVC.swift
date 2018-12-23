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

class PhotoAlbumVC: CoreDataViewController {
    

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var reloadButton: UIButton!
    
    var annotation: MKAnnotation!
    var pin: Pin!
    var photoPage = 1
    var retrievingPhotos = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        setupMap()
    }
    
    func setupMap() {
        map.addAnnotation(annotation)
        let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        map.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        
        if pin.photos?.count == 0 {
            getNewPhotos(photoPage)
            photoPage += 1
        }
    }
    
    @IBAction func relaodPhotos(_ sender: Any) {
        for photo in pin.photos! {
            fetchedResultsController?.managedObjectContext.delete(photo as! NSManagedObject)
        }
        let sharedDelegate = UIApplication.shared.delegate as! AppDelegate
        sharedDelegate.stack.save()
        
        getNewPhotos(photoPage)
        photoPage += 1
    }
    
    func storePhotos(_ photosDictionary: [[String: Any?]]) {
        DispatchQueue.main.async {
            self.collection.reloadData()
        }
        
        
        for photo in photosDictionary {
            let urlString = photo[FlickrProvider.ParameterValues.MediumURL] as! String?
            
            let url = URL(string: urlString!)
            
            if let imageData = try? Data(contentsOf: url!) {
                let p = Photo(data: imageData as NSData, pin: pin, context: (fetchedResultsController?.managedObjectContext)!)
                pin.addToPhotos(p)
            } else {
                print("No image.")
            }
        }
        
        retrievingPhotos = false
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).stack.save()
            self.collection.reloadData()
            self.enableUI(true)
        }
    }
    
    func getNewPhotos(_ pageNum: Int) {
        enableUI(false)
        retrievingPhotos = true
        
        let coord = annotation.coordinate
        FlickrProvider.sharedInstance.getPhotosforLocation(coord.latitude, coord.longitude, pageNum, { (success, photos) in
            func showAlert(_ errorString: String = "Could not connect to network."){
                let alert = UIAlertController(title: "Error", message:
                    errorString, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            guard success else {
                showAlert()
                return
            }
            
            if photos?.count == 0 {
                showAlert("Ruh Roh, no photos.")
                return
            }
            
            self.storePhotos(photos!)
        })
    }
    
    override func updateViewAfterChange() {
        guard (collection != nil) else { return }
        collection.reloadData()
    }
    
    func enableUI(_ enable: Bool) {
        reloadButton.isEnabled = enable
    }
}

extension PhotoAlbumVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView?.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
}

extension PhotoAlbumVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = pin.photos?.allObjects[indexPath.row] as! Photo
        fetchedResultsController?.managedObjectContext.delete(photo)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (pin.photos?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoCollectionViewCell
        
        DispatchQueue.main.async {
            if !self.retrievingPhotos {
                cell.photoCollectionViewCellImage.image = UIImage(data: (self.pin.photos?.allObjects[indexPath.row] as! Photo).data! as Data)
            } else {
                cell.photoCollectionViewCellImage.image = #imageLiteral(resourceName: "loading")
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width / 2) - 5
        return CGSize(width: width, height: width)
    }
    
}
