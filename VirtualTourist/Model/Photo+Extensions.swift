//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 12/21/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation
import CoreData


extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    @NSManaged public var data: NSData?
    @NSManaged public var pin: Pin?
    
}
