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
import SwiftyJSON

class Location {
    
    var name: String = ""
    var lat: CLLocationDegrees = CLLocationDegrees()
    var long: CLLocationDegrees = CLLocationDegrees()
    var coord: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var address: String = ""
    var placeID: String = ""
    var attributedText: String!
    var imageURL: URL!
    final let APIKey: String = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    var imageView: UIImageView = UIImageView()
    
    
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.lat = CLLocationDegrees(json["geometry"]["location"]["lat"].doubleValue)
        self.long = CLLocationDegrees(json["geometry"]["location"]["lng"].doubleValue)
        self.coord = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
        self.address = json["formatted_address"].stringValue
        self.placeID = json["place_id"].stringValue
        self.imageURL = URL(string: json["photos"][0]["html_attributions"][0].stringValue)
        print("The ref is \(json["photos"][0]["photo_reference"])")
        imageView.af_setImage(withURL: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxheight=400&photoreference=\(json["photos"][0]["photo_reference"])&key=AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8")! )
    }
    
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
    
