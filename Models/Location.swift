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
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class Location {
    
    var name: String = ""
    var lat: CLLocationDegrees = CLLocationDegrees()
    var long: CLLocationDegrees = CLLocationDegrees()
    var coord: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var address: String = ""
    var placeID: String = ""
    var attributedText: String!
    var imageURL: URL!
    var imageView: UIImageView = UIImageView()
    
    
    
    init(json: JSON) {
        self.name = json["name"].stringValue
        self.lat = CLLocationDegrees(json["geometry"]["location"]["lat"].doubleValue)
        self.long = CLLocationDegrees(json["geometry"]["location"]["lng"].doubleValue)
        self.coord = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
        self.address = json["formatted_address"].stringValue
        if self.address == "" || self.address == " "{
            self.address = json["vicinity"].stringValue
        }
        self.placeID = json["place_id"].stringValue
        self.imageURL = URL(string: json["photos"][0]["html_attributions"][0].stringValue)
        
    }
    
    convenience init(json: JSON, setImage: Bool, tableView: UITableView, controller: UIViewController) {
        self.init(json: json)
        if setImage {
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxheight=400&photoreference=\(json["photos"][0]["photo_reference"])&key=\(Constants.APIKey.web)")
            Alamofire.request(url!).validate().responseImage(completionHandler: { (response) in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        self.imageView.image = value
                        tableView.reloadData()
                    }
                case .failure(let error):
                    controller.present(Constants.Error.errorController, animated: true, completion: nil)
                    print("Error: \(error.localizedDescription)")
                }
                
            })
            
        }
        
    }
    
    convenience init(json: JSON, setImage: Bool, collectionView: UICollectionView) {
        self.init(json: json)
        if setImage {
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxheight=400&photoreference=\(json["photos"][0]["photo_reference"])&key=\(Constants.APIKey.web)")
            Alamofire.request(url!).validate().responseImage(completionHandler: { (response) in
                switch response.result {
                case .success:
                    if let value = response.result.value {
                        self.imageView.image = value
                        collectionView.reloadData()
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                
            })
            
        }
        
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

