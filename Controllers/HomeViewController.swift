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
    
    @IBOutlet weak var tableView: UITableView!
    weak var markerLocation: GMSPlace!
    
    var destinations: [GMSPlace] = []
    
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
    
    @IBAction func mapButtonPressed(_ sender: Any) {
        //does nothing for now
        
    }
    
    @IBAction func unwindToHomeViewController(_ segue: UIStoryboardSegue) {
        
        // for now, simply defining the method is sufficient.
        // we'll add code later
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toMapView" {
                if let nextViewController = segue.destination as? MapViewController {
                    nextViewController.destinationList = destinations
                }
            }
        }
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
        markerLocation = place
        destinations.append(place)
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
        print("Return destination count: \(destinations.count)")
        return destinations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("enter method")
        let cell = tableView.dequeueReusableCell(withIdentifier: "listDestinationsTableViewCell", for: indexPath) as! ListDestinationsTableViewCell
        let place = destinations[indexPath.row]
        cell.destinationTextLabel.text = place.name
        print("Returning cell: \(place.name)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Returning height")
        return 50
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            destinations.remove(at: indexPath.row)
        }
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selection made")
    }
}
