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


class HomeViewController: UIViewController {
    @IBOutlet weak var notCoolLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var destinations:[Location] = []
    var destinationCells: [ListDestinationsTableViewCell] = []
    
    var count = 0
    
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
        
        if count < 10{
            notCoolLabel.text = "Not Cool\nFollow Directions"
        } else if count < 20 {
            notCoolLabel.text = "Plz Stop"
        } else if count < 30 {
            notCoolLabel.text = "Help, I'm scared..."
        } else if count < 40 {
            notCoolLabel.text = "I give up"
        } else if count < 50 {
            notCoolLabel.text = "YOU SHALL DIE!!  jk\nBut actually stop tho"
        } else if count < 60 {
            notCoolLabel.text = ""
        } else if count == 63 {
            notCoolLabel.text = "You know what?"
        } else if count == 64 {
            notCoolLabel.text = "BLUE SCREEN OF DEATH IN 3..."
        } else if count == 65 {
            notCoolLabel.text = "2..."
        } else if count == 66 {
            notCoolLabel.text = "1..."
        } else if count == 67 {
            notCoolLabel.text = "Last Chance...."
        } else if count == 68 {
            notCoolLabel.text = "K NOW YOU DESERVE IT"
        } else if count == 69 {
            notCoolLabel.text = "bye"
        } else if count >= 70 {
            notCoolLabel.text = ""
            count = 0
            performSegue(withIdentifier: "toBlueScreen", sender: self)
        }
        count += 1
    }
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        //does nothing for now
        
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
            print("Button pressed")
    }
    
    @IBAction func unwindToHomeViewController(_ segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Starting to segue")
        if let identifier = segue.identifier {
            if identifier == "toMapView" {
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.destinationList = destinations
                }
            } 
        }
        print("End of segue")
    }
    
    @IBAction func autocompleteButtonPressed(_ sender: UIButton) {
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        
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
        count = 0
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "toMapView", sender: self)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        print("Autocomplete election made!")
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
        print("Selection made")
    }
}
