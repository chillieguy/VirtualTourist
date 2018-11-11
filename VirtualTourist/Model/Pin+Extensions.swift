//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 11/7/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        createdDate = Date()
        id = UUID()
        print(id!)
        
    }
}
