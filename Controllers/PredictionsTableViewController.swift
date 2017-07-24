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

class PredictionsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var unfilteredPlaces: [String] = ["San Jose", "San Francisco", "Hacker Dojo", "California", "Subway", "Taco Bell",
                                      "Pho Van"]
    var filteredPlaces: [String]?
    let searchController = UISearchController(searchResultsController: nil)
    let APIKey = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredPlaces = unfilteredPlaces
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.dismiss(animated: false, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let places = filteredPlaces else { return 0 }
        return places.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! ListPredictionsTableViewCell
        if let places = filteredPlaces {
            cell.predictionLabel.text = "Hello! This is the cell for \(places[indexPath.row])"
        }
        return cell
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text?.replacingOccurrences(of: " ", with: "+"), !searchText.isEmpty {
            
            let url = URL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchText)&key=\(APIKey)")
            Alamofire.request(url!).validate().responseJSON() { (response) in
                switch response.result {
                    
                case .success:
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        print("JSON Status is : \(json["status"])")
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
            filteredPlaces = unfilteredPlaces.filter{ places in
                return places.lowercased().contains(searchText.lowercased())
            }
        } else {
            filteredPlaces = unfilteredPlaces
        }
        
        tableView.reloadData()
    }
    
    
    
}
