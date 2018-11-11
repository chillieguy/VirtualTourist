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
    var pin: Pin!
    
    var dataController: DataController!
    
    let flickrProvider = FlickrProvider()
    // Hold coord of a specific annotation
    var coord = CLLocationCoordinate2D()
    
    var isEditingPins = false
    let editView = UIView()
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var rightNavButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            pins = result
            
        }
        
        setupRemovePinButton()
        populateMapWithPins()
        setupGestureRecognizer()
        
        print("Pin count: \(fetchAllPins().count)")
        // TODO: Add UserDefaults for restoring map position
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rightNavButton.title = "Edit"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // TODO: Save UserDefaults for map position when view is left
        
        
    }
    
    func populateMapWithPins() {
        map.removeAnnotations(map.annotations)
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
        if !isEditingPins && gestureRecognizer.state == UIGestureRecognizer.State.began {
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
        
    }
    
    func setupRemovePinButton() {
        view.addSubview(editView)
        editView.backgroundColor = UIColor.white
        editView.translatesAutoresizingMaskIntoConstraints = false
        editView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        editView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        editView.topAnchor.constraint(equalTo: map.bottomAnchor).isActive = true
        editView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        let editTextLabel = UILabel()
        editView.addSubview(editTextLabel)
        editTextLabel.translatesAutoresizingMaskIntoConstraints = false
        editTextLabel.centerXAnchor.constraint(equalTo: editView.centerXAnchor).isActive = true
        editTextLabel.centerYAnchor.constraint(equalTo: editView.centerYAnchor).isActive = true
        editTextLabel.widthAnchor.constraint(equalTo: editView.widthAnchor).isActive = true
        editTextLabel.heightAnchor.constraint(equalTo: editView.heightAnchor, multiplier: 0.5).isActive = true
        editTextLabel.text = "TAP PIN TO DELETE"
        editTextLabel.textAlignment = .center
        editTextLabel.font = UIFont(name: "Avenir-BlackOblique", size: 32)
        
    }
    
    @IBAction func editAction(_ sender: Any) {
        if !isEditingPins {
            rightNavButton.title = "Done"
            isEditingPins = true
            
        } else {
            rightNavButton.title = "Edit"
            isEditingPins = false
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let photoAlbumVC = segue.destination as? PhotoAlbumVC {
            
            photoAlbumVC.coord = coord
            photoAlbumVC.dataController = dataController
            
        }
        
    }

}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else { return }
        let pin = searchPin(annotation: annotation)
        
        if isEditingPins {
            mapView.removeAnnotation(annotation)
            
            dataController.viewContext.delete(pin)
            try? dataController.viewContext.save()
            
            
        } else {
            coord = (view.annotation?.coordinate)!
            map.deselectAnnotation(view.annotation, animated: true)
            
            performSegue(withIdentifier: "photoAlbumSegue", sender: nil)
        }
        
    }
}

extension MapVC {
    
    func fetchAllPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        return try! dataController.viewContext.fetch(fetchRequest) as! [Pin]
    }
    
    func searchPin(annotation: MKAnnotation) -> Pin {
        let returnPin = fetchAllPins().filter { $0.latitude == annotation.coordinate.latitude && $0.longitude == annotation.coordinate.longitude}.first!
        
        return returnPin
    }
    
}

