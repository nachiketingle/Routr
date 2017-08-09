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

class HomeViewController: UIViewController {

    @IBOutlet weak var finalDestinationLabel: UILabel!
    @IBOutlet weak var autocompleteButton: UIButton!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var notCoolLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var destinations:[Location] = []
    var finalDestination: Location?
    //var destinationCells: [ListDestinationsTableViewCell] = []
    
    var selectedPlace: String? = nil
    var notCoolTexts = NotCoolTexts()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDesign()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        //tableView.separatorStyle = .none

        tableView.reloadData()
    }
    
    func setDesign() {
        //navigationController?.navigationBar.isOpaque = true
        //navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = Constants.Colors.purple
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
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
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        //does nothing for now
        
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
        
        if let place = selectedPlace {
            
            notCoolLabel.text = "LOADING..."
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place)&key=\(Constants.APIKey.web)")
            
            Alamofire.request(url!).validate().responseJSON { (response) in
                switch response.result {
                    
                case .success:
                    print("Success")
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        print("Status: \(json["status"])")
                        if json["status"] == "OK"{
                            self.destinations.append( Location( json: json["result"] ) )
                        }
                        
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                
                self.notCoolLabel.text = "Finished"
                self.tableView.reloadData()
            }
            selectedPlace = nil
        }
        
        
        tableView.reloadData()
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
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
        /*
         let cell = tableView.dequeueReusableCell(withIdentifier: "listDestinationsTableViewCell") as! ListDestinationsTableViewCell
         cell.setLocation(to: location)
         destinationCells.append(cell)
         print(destinationCells)
         */
        notCoolLabel.text = "Marker shall be placed on map"
        notCoolTexts.arrayCounter = 0
        mapButton.isEnabled = true
        autocompleteButton.isEnabled = true
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "toMapView", sender: self)
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
        //print("enter method")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listDestinationsTableViewCell", for: indexPath) as! ListDestinationsTableViewCell
        let place = destinations[indexPath.row]
        cell.destinationTextLabel.text = place.name
        cell.addressTextLabel.text = place.address
        cell.backgroundColor = Constants.Colors.purple
        //print("Returning cell: \(place.name)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Returning height")
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Selection at: \(indexPath.row)")
            if finalDestination?.placeID == destinations[indexPath.row].placeID {
                finalDestination = nil
                finalDestinationLabel.text = "Select a Destination"
            }
            destinations.remove(at: indexPath.row)
            
            self.tableView.reloadData()
            //destinationCells.remove(at: indexPath.row)
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
