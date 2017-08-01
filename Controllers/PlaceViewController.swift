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
import AlamofireNetworkActivityIndicator

class PlaceViewController: UIViewController {
    
    //var selectedPlace: GMSPlace?
    var selectedPlace: Location?
    var placesList: [Location] = []
    let APIKey = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    let APIKeyDir = "AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8"
    var placesClient = GMSPlacesClient.shared()
    var count = 0
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var placeID: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        print("Started to load PlaceViewController")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if placeID == nil {
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.tintColor = nil
        }
        
        listNearbyPlaces()
        
        tableView.reloadData()
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "selectionMade" {
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.selectedPlace = selectedPlace
                    print("Selection has been made \(nextViewController.count)")
                }
            } else if identifier == "cancel" {
                print("Cancel button is presesed")
            } else if identifier == "removeMarker" {
                //remove marker function
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.removeMarker = placeID
                    placeID = nil
                }
            }
        }
    }
    
    func listNearbyPlaces() {

        placesList.removeAll()
        

        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat!),\(long!)&radius=30000&keyword=attraction&key=\(APIKeyDir)")
        print("Latitude: \(lat!), Longitude: \(long!)")
        Alamofire.request(url!).validate().responseJSON() { (response) in
            switch response.result {
                
            case .success:
                if let value = response.result.value {
                    let json = JSON(json: value)
                    let max: Int!
                    if json["results"].count >= 10 {
                        max = 10
                    } else {
                        max = json["results.count"].count - 1
                    }
                    
                    print("JSON status for placeVC: \(json["status"])")
                    for count in 0...max {
                        self.placesList.append( Location(json: json["results"][count], setImage: true, tableView: self.tableView) )
                        print("Appended: \(json["results"][count]["name"].stringValue)")
                    }
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                
            }
            
            
        }
    }
    @IBAction func removePlacePressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "removeMarker", sender: self)
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
        return placesList.count
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
        selectedPlace = placesList[indexPath.row]
        //print("Selection continued")
        performSegue(withIdentifier: "selectionMade", sender: self)
    }
}
