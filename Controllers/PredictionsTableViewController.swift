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
    
    var unfilteredPlaces: [String] = ["San Jose", "San Francisco", "Hacker Dojo", "California", "Subway", "Taco Bell",
                                      "Pho Van"]
    var filteredPlaces: [String]?
    
    var predictedPlaces: [BasicLocation] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    let APIKey = "AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8"
    var selectedPlace: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //filteredPlaces = unfilteredPlaces
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
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
                    nextViewController.selectedPlace = selectedPlace!
                    print("New location has been added")
                }
            }
        }
        print("End of segue")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //guard let places = predictedPlaces else { return 0 }
        return predictedPlaces.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! ListPredictionsTableViewCell
        //if let places = predictedPlaces {
            cell.predictionLabel.text = predictedPlaces[indexPath.row].name
        //}
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height / 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = predictedPlaces[indexPath.row].placeID
        performSegue(withIdentifier: "unwindToHome", sender: self)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        //DO NOTHING HERE
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text?.replacingOccurrences(of: " ", with: "+"), !searchText.isEmpty {
            
            
             let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(searchText)&location=0,0&radius=20000000&key=\(APIKey)")
             Alamofire.request(url!).validate().responseJSON() { (response) in
             switch response.result {
             
             case .success:
             
                if let value = response.result.value {
                    let json = JSON(value)
                    print("JSON Status is : \(json["status"])")
                    print("JSON Error: \(json["error_message"])")
                    self.predictedPlaces.removeAll()
                    
                    for count in 0...json["predictions"].count-1 {
                        self.predictedPlaces.append(BasicLocation(json: json["predictions"][count]))
                        print("Appended: \(self.predictedPlaces[count].name)")
                    }
                    self.tableView.reloadData()
                }
             
             case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        }
        
        //tableView.reloadData()
    }
}
