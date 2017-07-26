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
    var count = 0
    let APIKeyDir = "AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        //tableView.separatorStyle = .none
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
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
        count += 1
    }
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        //does nothing for now
        
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
            print("Button pressed")
    }
    
    @IBAction func autocompleteButtonPressed(_ sender: UIButton) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    @IBAction func unwindToHomeViewController(_ segue: UIStoryboardSegue) {
        
        if let place = selectedPlace {
            
            notCoolLabel.text = "LOADING..."
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(place)&key=\(APIKeyDir)")
            
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
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.destinations = destinations
                    nextViewController.endPoint = finalDestination
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
            destinations.remove(at: indexPath.row)
            self.tableView.reloadData()
            //destinationCells.remove(at: indexPath.row)
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finalDestination = destinations[indexPath.row]
        finalDestinationLabel.text = finalDestination?.name
        print("Selection made")
    }
}
