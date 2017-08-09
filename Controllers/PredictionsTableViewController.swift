//
//  PredictionsTableViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 7/21/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftyJSON

class PredictionsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    var predictedPlaces: [BasicLocation] = []
    var selectedPlace: String?
    var resultAvailable: Bool = true
    let searchController = UISearchController(searchResultsController: nil)
    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = Constants.Colors.purple
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.title = "Search for a place"
        navigationController?.navigationItem.title = "Search for a place"
        //filteredPlaces = unfilteredPlaces
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = Constants.Colors.purple
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.keyboardType = .alphabet
        
        tableView.backgroundColor = Constants.Colors.purple
        tableView.separatorColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Starting to segue")
        if let identifier = segue.identifier {
            if identifier == "unwindToHome" {
                if let nextViewController = segue.destination as? HomeViewController {
                    self.dismiss(animated: true, completion: nil)
                    nextViewController.selectedPlace = selectedPlace!
                    print("New location has been added")
                }
            }
        }
        print("End of segue")
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //guard let places = predictedPlaces else { return 0 }
        if !resultAvailable {
            return 1
        }
        return predictedPlaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! ListPredictionsTableViewCell
        if resultAvailable {
            cell.predictionLabel.text = predictedPlaces[indexPath.row].name
            cell.isUserInteractionEnabled = true
            if !predictedPlaces[indexPath.row].secondaryText.contains(",") {
                predictedPlaces[indexPath.row].secondaryText = "Please select a more specific location"
                cell.isUserInteractionEnabled = false
            }
            cell.secondaryLabel.text = predictedPlaces[indexPath.row].secondaryText
        } else {
            cell.predictionLabel.text = "No results available"
            cell.isUserInteractionEnabled = false
            cell.secondaryLabel.text = ""
        }
        
        cell.backgroundColor = Constants.Colors.purple
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if predictedPlaces[indexPath.row].secondaryText != "Please select a more specific location" {
            selectedPlace = predictedPlaces[indexPath.row].placeID
            performSegue(withIdentifier: "unwindToHome", sender: self)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //DO NOTHING HERE
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if (searchController.searchBar.text?.isEmpty)! {
            return
        }
        if let searchText = searchController.searchBar.text?.replacingOccurrences(of: " ", with: "+"), !searchText.isEmpty {
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchText)&location=0,0&radius=20000000&key=\(Constants.APIKey.web)")
            Alamofire.request(url!).validate().responseJSON() { (response) in
                switch response.result {
                    
                case .success:
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON Status is : \(json["status"])")
                        print("JSON Error: \(json["error_message"])")
                        self.predictedPlaces.removeAll()
                        if json["status"].stringValue == "OK" {
                            for count in 0...json["predictions"].count-1 {
                                self.predictedPlaces.append(BasicLocation(json: json["predictions"][count]))
                                print("Appended: \(self.predictedPlaces[count].name)")
                                self.resultAvailable = true
                            }
                        } else {
                            self.resultAvailable = false
                        }
                        self.tableView.reloadData()
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        }
    }
}
