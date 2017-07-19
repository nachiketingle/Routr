//
//  ListDestinationsTableViewCell.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/14/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit

class ListDestinationsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var destinationTextLabel: UILabel!
    
    weak var place: Location!
    
    func setLocation(to location: Location) {
        place = location
        
        destinationTextLabel.text = place.name
    }
    
}
