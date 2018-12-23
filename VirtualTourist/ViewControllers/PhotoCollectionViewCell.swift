//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Chuck Underwood on 11/12/18.
//  Copyright © 2018 Chuck Underwood. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoCollectionViewCellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.gray
    }
    
}
