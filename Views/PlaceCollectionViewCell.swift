//
//  PlaceCollectionViewCell.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 8/3/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import UIKit

class PlaceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placeTextLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var attributionTextLabel: UILabel!
    
    func setLocation(to place: Location) {
        placeTextLabel.text = place.name
        placeTextLabel.textColor = UIColor.white
        //print("AND HIS NAME IS: \(place.name) at \(place.address)")
        attributionTextLabel.text = place.address //place.attributedText
        attributionTextLabel.textColor = UIColor.white
        placeImageView.image = place.imageView.image
    }
    
}
