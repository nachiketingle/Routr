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
    
    
    func setLocation(to place: Location) {
        placeTextLabel.text = place.name
        print("AND HIS NAME IS: \(place.name)")
        attributionTextLabel.text = place.attributedText
        placeImageView.image = place.imageView.image
        if let url = place.imageURL {
            print(url.absoluteString)
            //placeImageView.af_setImage(withURL: url)
            //placeImageView.af_setImage(withURL: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU&key=AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8")!)
        }
        /*
        Alamofire.request(place.imageURL).validate().responseJSON { (response) in
            switch response.result {
                
            case .success:
                
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    print("Success: \(place.name), Status: \(json["status"])")
                    if json["status"] == "OK"{
                        //do nothing for now
                    } else {
                        let locationName = place.name.replacingOccurrences(of: " ", with: "+").lowercased()
                        place.imageURL = URL(string: "https://maps.googleapis.com/maps/api/streetview?size=300x200&location=\(locationName)&key=\(place.APIKey)")
                    }
                    
                    self.placeImageView.af_setImage(withURL: place.imageURL)
                    
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                print(place.imageURL.absoluteString)
            }
        }
        */
    }
    
}
