//
//  ListPlacesTableViewCell.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/13/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator
import SwiftyJSON

class ListPlacesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeTextLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var attributionTextLabel: UILabel!
    
    weak var place: Location!
    
    func setLocation(to location: Location) {
        place = location
        print("Starting to set cell params")
        placeTextLabel.text = place.name
        print("place name is fine")
        attributionTextLabel.text = place.attributedText
        print("attributions text is fine")
        print("Cell params set")
    }
    
    func setImage() {
        let location: String = place.name.replacingOccurrences(of: " ", with: "+").lowercased()
        let coordinates = "\(place.lat),\(place.long)"
        let urlToRequest = "https://maps.googleapis.com/maps/api/streetview/metadata?location=\(coordinates)&key=\(place.APIKey)"
        
        Alamofire.request(urlToRequest).validate().responseJSON { (response) in
            switch response.result {
                
            case .success:
                
                if let value = response.result.value {
                    
                    let json = JSON(value)
                    let url: URL!
                    print("Success: \(location), Status: \(json["status"])")
                    if json["status"] == "OK"{
                        url = URL(string: "https://maps.googleapis.com/maps/api/streetview?size=300x200&location=\(coordinates)&key=\(self.place.APIKey)")
                    } else {
                        url = URL(string: "https://maps.googleapis.com/maps/api/streetview?size=300x200&location=\(location)&key=\(self.place.APIKey)")
                    }
                    self.placeImageView.af_setImage(withURL: url)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
        print("Alamofire works")
    }
    
}
