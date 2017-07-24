//
//  BasicLocation.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/20/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BasicLocation {
    
    let name: String
    let placeID: String
    
    init(json: JSON) {
        name = json["description"].stringValue
        placeID = json["place_id"].stringValue
    }
}
