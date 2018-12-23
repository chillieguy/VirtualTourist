//
//  Pin.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 11/19/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    convenience init(lat: Double, lon: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = lat
            self.longitude = lon
        } else {
            fatalError("Unable to find \(context)!")
        }
    }

}
