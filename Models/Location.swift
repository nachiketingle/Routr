//
//  Location.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/18/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps

class Location {
    
    let name: String!
    let lat: CLLocationDegrees!
    let long: CLLocationDegrees!
    let coord: CLLocationCoordinate2D
    let attributedText: String!
    let APIKey: String = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    
    
    init(place: GMSPlace) {
        self.name = place.name
        self.attributedText = place.attributions?.string
        self.coord = place.coordinate
        self.lat = place.coordinate.latitude
        self.long = place.coordinate.longitude
        
        print("Normal params set")
        
        
    }
    
}
    
