//
//  HomeViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/12/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftyJSON

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var finalDestinationLabel: UILabel!
    @IBOutlet weak var autocompleteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var destinations:[Location] = []
    var finalDestination: Location?
    
    var selectedPlace: String? = nil
    
    var authorized: Bool = false
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        setDesign()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        //tableView.separatorStyle = .none
        
        UserDefaults.standard.set(false, forKey: "authorizationSet")
        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UserDefaults.standard.set(false, forKey: "authorizationSet")
    }
    
    func setDesign() {
        //navigationController?.navigationBar.isOpaque = true
        //navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.Colors.purple
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        //navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica", size: 21)]
        /*
         testButton.layer.cornerRadius = 3
         testButton.layer.borderColor = UIColor.white.cgColor
         testButton.layer.backgroundColor = Constants.Colors.purple.cgColor
         testButton.layer.borderWidth = 1.0
         testButton.titleLabel?.adjustsFontSizeToFitWidth = true
         */
        
        mapButton.layer.cornerRadius = 3
        mapButton.layer.borderColor = UIColor.white.cgColor
        mapButton.layer.backgroundColor = Constants.Colors.purple.cgColor
        mapButton.layer.borderWidth = 1.0
        mapButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        autocompleteButton.layer.cornerRadius = 3
        autocompleteButton.layer.borderColor = UIColor.white.cgColor
        autocompleteButton.layer.backgroundColor = Constants.Colors.purple.cgColor
        autocompleteButton.layer.borderWidth = 1.0
        autocompleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        finalDestinationLabel.backgroundColor = Constants.Colors.purple
        
        view.backgroundColor = Constants.Colors.purple
        tableView.backgroundColor = Constants.Colors.purple
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     @IBAction func testButtonPressed(_ sender: UIButton) {
     
     if notCoolTexts.arrayCounter >= notCoolTexts.notCoolArray.count-1 {
     notCoolTexts.arrayCounter = 0
     performSegue(withIdentifier: "toBlueScreen", sender: self)
     }
     notCoolLabel.text = notCoolTexts.notCoolArray[notCoolTexts.arrayCounter]
     notCoolTexts.arrayCounter += 1
     if notCoolLabel.text == notCoolTexts.disablePhrase {
     mapButton.isEnabled = false
     autocompleteButton.isEnabled = false
     }
     
     }
     */
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationManager.stopUpdatingLocation()
        manager.stopUpdatingLocation()
        if let authorization = UserDefaults.standard.value(forKey: "authorizationSet") as? Bool {
            if authorization {
                switch status {
                case .restricted:
                    print("Location access restricted")
                case .denied:
                    print("User denied access to this location")
                //mapView.isHidden = false
                case .notDetermined:
                    print("Location status is not determined")
                case .authorizedAlways:
                    print("Location status is OK")
                    self.performSegue(withIdentifier: "toMapView", sender: self)
                //fallthrough
                case .authorizedWhenInUse:
                    self.performSegue(withIdentifier: "toMapView", sender: self)
                    print("Location status is OK")
                }
            }
        }
        UserDefaults.standard.set(false, forKey: "authorizationSet")
    }
    
    
    
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "authorizationSet")
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                //create alert
                
                let alertController = UIAlertController(title: "Unable to use this function unless location services is enabled", message: "In order to enable location services, go to \"Settings\" -> \"Privacy\" -> \"Location Services\"", preferredStyle: .alert)
                let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
                alertController.addAction(action)
                present(alertController, animated: true, completion: nil)
                
                print("was denied")
            case .authorizedAlways, .authorizedWhenInUse:
                performSegue(withIdentifier: "toMapView", sender: self)
            }
        } else {
        }
    }
    
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        print("Button pressed")
    }
    @IBAction func autocompleteButtonPressed(_ sender: Any) {
        if destinations.count < 15 {
            performSegue(withIdentifier: "toPredictions", sender: self)
        } else {
            let alertController = UIAlertController(title: "Cannot Add More Places", message: "You have too many places. Remove some to add more.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func unwindToHomeViewController(_ segue: UIStoryboardSegue) {
        
        print("Unwinding to HomeViewController")
        
        if let placeID = selectedPlace {
            
            print("PlaceID is: " + placeID)
            
            for location in destinations {
                if location.placeID == placeID {
                    selectedPlace = nil
                    print("Duplicate location")
                    return
                }
            }
            
            finalDestinationLabel.text = "LOADING..."
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=\(Constants.APIKey.web)")
            
            Alamofire.request(url!).validate().responseJSON { (response) in
                switch response.result {
                    
                case .success:
                    print("Success")
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        print("Status: \(json["status"])")
                        if json["status"] == "OK"{
                            self.destinations.append( Location( json: json["result"] ) )
                            print("New Location")
                            if let final = self.finalDestination {
                                self.finalDestinationLabel.text = "Final Destination:\n" + final.name
                            } else {
                                self.finalDestinationLabel.text = "Select A Destination"
                            }
                        }
                        
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                self.tableView.reloadData()
            }
            selectedPlace = nil
        }
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Starting to segue 1.0")
        if let identifier = segue.identifier {
            if identifier == "toMapView" {
                if let nextViewController = segue.destination as? UINavigationController {
                    if let controller = nextViewController.topViewController as? MapViewController {
                        print("Starting to prepare mapViewController")
                        controller.destinations = destinations
                        controller.endPoint = finalDestination
                        controller.locationManager = self.locationManager
                    }
                }
            }
        }
        print("End of segue 1.0")
    }
    
}

extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        //selection has been made
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "none")")
        print("Place attributions: \(String(describing: place.attributions))")
        let location = Location(place: place)
        destinations.append(location)
        
        mapButton.isEnabled = true
        autocompleteButton.isEnabled = true
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        print("Autocomplete selection made!")
        return true
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Return destination cell count: \(destinations.count)")
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listDestinationsTableViewCell", for: indexPath) as! ListDestinationsTableViewCell
        let place = destinations[indexPath.row]
        cell.destinationTextLabel.text = place.name
        cell.addressTextLabel.text = place.address
        cell.backgroundColor = Constants.Colors.purple
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Selection at: \(indexPath.row)")
            if finalDestination?.placeID == destinations[indexPath.row].placeID {
                finalDestination = nil
                finalDestinationLabel.text = "Select A Destination"
            }
            
            if self.destinations.isEmpty {
                self.finalDestinationLabel.text = "Add a Destination"
            } else {
                self.finalDestinationLabel.text = "Select a Destination"
            }
            
            destinations.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finalDestination = destinations[indexPath.row]
        finalDestinationLabel.text = "Final Destination:\n" + (finalDestination?.name)!
        print("Selection made")
    }
}
