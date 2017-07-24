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
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftyJSON

class Location {
    
    let name: String
    let lat: CLLocationDegrees
    let long: CLLocationDegrees
    let coord: CLLocationCoordinate2D
    let address: String
    let placeID: String
    let attributedText: String!
    var imageURL: URL!
    final let APIKey: String = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    var imageView: UIImageView!
    
    
    init(place: GMSPlace) {
        self.name = place.name
        self.attributedText = place.attributions?.string
        self.coord = place.coordinate
        self.lat = place.coordinate.latitude
        self.long = place.coordinate.longitude
        self.address = place.formattedAddress!
        self.placeID = place.placeID
        print("Normal params set")
        
        /*
        let coordinates = "\(lat),\(long)"
        self.imageURL = URL(string: "https://maps.googleapis.com/maps/api/streetview/metadata?size=300x200&location=\(coordinates)&key=\(APIKey)")
        
        Alamofire.request(imageURL).validate().responseJSON { (response) in
            switch response.result {
                
            case .success:
                
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print("Success: \(place.name), Status: \(json["status"])")
                    if json["status"] == "OK"{
                        self.imageURL = URL(string: "https://maps.googleapis.com/maps/api/streetview/metadata?size=300x200&location=\(coordinates)&key=\(self.APIKey)")
                    } else {
                        let locationName = place.name.replacingOccurrences(of: " ", with: "+").lowercased()
                        self.imageURL = URL(string: "https://maps.googleapis.com/maps/api/streetview?size=300x200&location=\(locationName)&key=\(self.APIKey)")
                    }
                    
                    self.imageView.af_setImage(withURL: self.imageURL)
                    
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        */
    }
    
}
    
