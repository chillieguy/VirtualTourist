//
//  Pin.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 11/19/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    
    convenience init(latitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.latitude = latitude
        
    }
    
    convenience init(longitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        self.init(entity: entity, insertInto: context)
        
        self.longitude = longitude
        
    }

}
