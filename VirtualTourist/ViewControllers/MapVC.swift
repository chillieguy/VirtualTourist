//
//  MapVC
//  VirtualTourist
//
//  Created by Chuck Underwood on 10/23/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapVC: CoreDataViewController {
    
    var dataController: DataController!
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        loadPins()
        setupGestureRecognizer()
        setupData()
        
    }
    
    func setupData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fetchedResource = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fetchedResource.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchedResource, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func loadPins() {
        if let pins = fetchedResultsController?.fetchedObjects as! [Pin]? {
            for pin in pins {
                let coords = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coords
                if !map.annotations.contains(where: { (mk) -> Bool in
                    return mk.coordinate.latitude == annotation.coordinate.latitude && mk.coordinate.longitude == annotation.coordinate.longitude
                }) {
                    map.addAnnotation(annotation)
                }
            }
        }
    }
    
    func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        map.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureRecognizer.location(in: map)
            let coords = map.convert(touchPoint, toCoordinateFrom: map)
            
            let _ = Pin(lat: coords.latitude, lon: coords.longitude, context: (fetchedResultsController?.managedObjectContext)!)
            let sharedDelegate = UIApplication.shared.delegate as! AppDelegate
            sharedDelegate.stack.save()
        }
        
    }
    
    override func updateViewAfterChange() {
        loadPins()
    }
    
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .green
            pinView?.animatesDrop = true
            pinView?.isDraggable = false
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumVC") as! PhotoAlbumVC
        vc.annotation = view.annotation
        vc.pin = getLocation((view.annotation?.coordinate)!)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        vc.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (fetchedResultsController?.managedObjectContext)!, sectionNameKeyPath: nil, cacheName: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MapVC {
    
    func getLocation(_ coordinates: CLLocationCoordinate2D) -> Pin? {
        for obj in (fetchedResultsController?.fetchedObjects)! {
            let loc = obj as? Pin
            if loc?.latitude == coordinates.latitude && loc?.longitude == coordinates.longitude {
                return obj as? Pin
            }
        }
        return nil
    }
}

