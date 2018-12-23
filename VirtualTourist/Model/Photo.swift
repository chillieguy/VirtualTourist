//
//  Photo.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 12/21/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(data: NSData, pin: Pin, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.data = data
            self.pin = pin
        } else {
            fatalError("Unable to find \(pin)")
        }
    }
    
}

