//
//  CoreDataViewController.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 12/22/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            fetchedResultsController?.delegate = self
            executeSearch()
            updateViewAfterChange()
        }
    }
    
    func executeSearch() {
        if let fetchedResults = fetchedResultsController {
            do {
                try fetchedResults.performFetch()
            } catch let error as NSError {
                print("Error while trying to search: \n\(error):(fetchedResultsController!)")
            }
        }
    }
    
    func updateViewAfterChange() {
        fatalError("")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateViewAfterChange()
    }
}
