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

class MapVC: UIViewController {
    
    // The Pin object to populate map
    var pins: [Pin] = []
    
    var dataController: DataController!
    
    let flickrProvider = FlickrProvider()
    // Hold coord of a specific annotation
    var coord = CLLocationCoordinate2D()
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            
        }
        
        populateMapWithPins()
        setupGestureRecognizer()
        
        // TODO: Add UserDefaults for restoring map position
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // TODO: Save UserDefaults for map position when view is left
        
        
    }
    
    func populateMapWithPins() {
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            map.addAnnotation(annotation)
        }
    }
    
    func setupGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        map.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let location = gestureRecognizer.location(in: map)
        let coordinate = map.convert(location, toCoordinateFrom: map)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        try? dataController.viewContext.save()
        
    }
    
    @IBAction func editAction(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let photoAlbumVC = segue.destination as? PhotoAlbumVC {
            photoAlbumVC.coord = coord
    
        }
        
    }

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        coord = (view.annotation?.coordinate)!
        map.deselectAnnotation(view.annotation, animated: true)

        performSegue(withIdentifier: "photoAlbumSegue", sender: nil)
    }
}

