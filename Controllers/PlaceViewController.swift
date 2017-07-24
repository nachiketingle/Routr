//
//  PlaceViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/12/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire
import AlamofireImage
import AlamofireNetworkActivityIndicator

class PlaceViewController: UIViewController {
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var placesList: [Location] = []
    let APIkey = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    var placesClient = GMSPlacesClient.shared()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //set number of places to just 10
        if likelyPlaces.count > 10 {
            let range: ClosedRange<Int> = ClosedRange(uncheckedBounds: (lower: 15, upper: likelyPlaces.count - 1))
            likelyPlaces.removeSubrange(range)
        }
        
        
        for place in likelyPlaces {
            placesList.append(Location(place: place))
        }
        
        
        tableView.reloadData()
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "selectionMade" {
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.selectedPlace = selectedPlace
                    print("Selection has been made")
                }
            } else if identifier == "cancel" {
                print("Cancel button is presesed")
            }
        }
    }
    
}

extension PlaceViewController: UITableViewDataSource {
    
    //unused function
    func loadImageForMetaData(photoMetaData: GMSPlacePhotoMetadata, cell: ListPlacesTableViewCell) {
        placesClient.loadPlacePhoto(photoMetaData) { (photo, error) in
            if let error = error {
                print("Photo error: \(error.localizedDescription)")
                return
            }
            cell.placeImageView.image = photo
            cell.attributionTextLabel.text = photoMetaData.attributions?.string
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("Returning number of rows: \(likelyPlaces.count)")
        
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listPlacesTableViewCell", for: indexPath) as! ListPlacesTableViewCell
        
        cell.setLocation(to: placesList[indexPath.row])
        return cell
        //return placesList[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Returning height")
        return self.tableView.frame.size.height / 4
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
    
}

extension PlaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Selection started")
        selectedPlace = likelyPlaces[indexPath.row]
        //print("Selection continued")
        performSegue(withIdentifier: "selectionMade", sender: self)
    }
}
