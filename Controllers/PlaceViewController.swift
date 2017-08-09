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
    
    /***************
    
     Things to do:
     -collection view
     -scroll for type of places other than attractions
     
    ******************/
    
    //var selectedPlace: GMSPlace?
    var selectedPlace: Location?
    var placesList: [Location] = []
    var placesClient = GMSPlacesClient.shared()
    var count = 0
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var placeID: String?
    var types: [String]!
    var selectedType: String? = "Attractions"
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var typePicker: UIPickerView!
    
    override func viewDidLoad() {
        print("Started to load PlaceViewController")
        
        types = ["Attractions", "Hotels", "Restaurants", "Gas Stations"]
        
        self.typePicker.delegate = self
        self.typePicker.dataSource = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        setDesign()
        
        listNearbyPlaces()
        
        typePicker.reloadAllComponents()
        tableView.reloadData()
        super.viewDidLoad()
    }
    
    func setDesign() {
        
        view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.5)
        view.isOpaque = false
        
        popupView.layer.cornerRadius = 10
        
        self.tableView.layer.cornerRadius = 10
        
        if placeID == nil {
            removeButton.isEnabled = false
            removeButton.tintColor = UIColor.clear
            //navigationItem.rightBarButtonItem?.isEnabled = false
            //navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        } else {
            removeButton.isEnabled = true
            removeButton.tintColor = nil
            //navigationItem.rightBarButtonItem?.isEnabled = true
            //navigationItem.rightBarButtonItem?.tintColor = nil
        }
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
        
        let keyword = selectedType?.replacingOccurrences(of: " ", with: "+")
        print(keyword!)
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat!),\(long!)&radius=20000&keyword=\(keyword!)&key=\(Constants.APIKey.web)")
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
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "removeMarker", sender: self)
    }
    
    
}

extension PlaceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return types.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print("Title for \(row) is \(types[row])")
        return types[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected: \(types[row])")
        selectedType = types[row]
        listNearbyPlaces()
    }
    
}

extension PlaceViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Selection started")
        selectedPlace = placesList[indexPath.row]
        //print("Selection continued")
        performSegue(withIdentifier: "selectionMade", sender: self)
    }
    
}


