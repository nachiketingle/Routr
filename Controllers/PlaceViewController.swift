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

class PlaceViewController: UIViewController {
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    
    var placesClient = GMSPlacesClient.shared()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.reloadData()
        
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
    
    func loadImageForMetaData(photoMetaData: GMSPlacePhotoMetadata, cell: ListPlacesTableViewCell) {
        placesClient.loadPlacePhoto(photoMetaData) { (photo, error) in
            if let error = error {
                print("Photo error: \(error.localizedDescription)")
                return
            }
            cell.placeImageView.image = photo
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning number of rows: \(likelyPlaces.count)")
        return likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listPlacesTableViewCell", for: indexPath) as! ListPlacesTableViewCell
        let place = likelyPlaces[indexPath.row]
        
        print("This places should be shown: \(place.name)")
        
        //let location: String = place.name.replacingOccurrences(of: " ", with: "+")
        
        placesClient.lookUpPhotos(forPlaceID: place.placeID) { (placePhotoMetaData, error) in
            if let error = error {
                print("Photo metadata error: \(error.localizedDescription)")
                return
            }
            if let firstPhoto = placePhotoMetaData?.results.first {
                self.loadImageForMetaData(photoMetaData: firstPhoto, cell: cell)
            }
        }
        
        cell.placeTextLabel.text = place.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("Returning height")
        return self.tableView.frame.size.height / 5
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
        print("Selection started")
        selectedPlace = likelyPlaces[indexPath.row]
        print("Selection continued")
        performSegue(withIdentifier: "selectionMade", sender: self)
    }
}
