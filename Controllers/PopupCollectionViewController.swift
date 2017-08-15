//
//  PopupCollectionViewController.swift
//  GoogleMapsAPITest
//
//  Created by Nachiket on 8/3/17.
//  Copyright © 2017 Nachiket. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import Alamofire
import AlamofireNetworkActivityIndicator
import SwiftyJSON
import Answers

class PopupCollectionViewController: UIViewController {
    
    var selectedPlace: Location?
    var placesList: [Location] = []
    var placesClient = GMSPlacesClient.shared()
    var count = 0
    var lat: CLLocationDegrees!
    var long: CLLocationDegrees!
    var placeID: String?
    var types: [String] = ["Attractions", "Hotels", "Restaurants", "Parks"]
    var selectedType: String = "Attractions"
    var typeAlertController: UIAlertController = UIAlertController(title: nil, message: "Pick a type of place", preferredStyle: .actionSheet)
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var typesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Started to load PlaceViewController")
        
        for type in types {
            let action = UIAlertAction(title: type, style: .default) { (action) in
                self.selectedType = type
                self.listNearbyPlaces()
                Answers.logCustomEvent(withName: "Changed Type", customAttributes: ["Type" : type])
                self.collectionView.reloadData()
            }
            typeAlertController.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        typeAlertController.addAction(cancelAction)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.purple
        
        setDesign()
        
        listNearbyPlaces()
        collectionView.reloadData()
    }
    
    func setDesign() {
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isOpaque = false
        
        popupView.layer.cornerRadius = 10
        popupView.backgroundColor = Constants.Colors.purple
        
        collectionView.backgroundColor = Constants.Colors.purple
        collectionView.layer.cornerRadius = 10
        typesButton.titleLabel?.textAlignment = .center
        typesButton.titleLabel?.text = selectedType
        typesButton.titleLabel?.adjustsFontSizeToFitWidth = true

        typesButton.backgroundColor = Constants.Colors.purple
        typesButton.layer.borderColor = UIColor.white.cgColor
        typesButton.layer.borderWidth = 1.0
        typesButton.layer.cornerRadius = 2.0
        typesButton.titleLabel?.textColor = UIColor.white
        
        closeButton.backgroundColor = Constants.Colors.purple
        closeButton.layer.borderColor = UIColor.white.cgColor
        closeButton.layer.borderWidth = 1.0
        closeButton.layer.cornerRadius = 2.0
        closeButton.titleLabel?.textColor = UIColor.white
        
        removeButton.setTitleColor(UIColor.white, for: .disabled)
        removeButton.setTitleColor(UIColor.white, for: .normal)
        if placeID == nil {
            removeButton.isEnabled = false
            removeButton.tintColor = nil
            print("PlaceID is nil")
            //removeButton.titleLabel?.text = "~"
            removeButton.setTitle("~", for: .normal)
            removeButton.backgroundColor = Constants.Colors.purple
            removeButton.layer.borderColor = UIColor.white.cgColor
            removeButton.layer.borderWidth = 1.0
            removeButton.layer.cornerRadius = 2.0
            //navigationItem.rightBarButtonItem?.isEnabled = false
            //navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        } else {
            removeButton.isEnabled = true
            removeButton.tintColor = nil
            //navigationItem.rightBarButtonItem?.isEnabled = true
            //navigationItem.rightBarButtonItem?.tintColor = nil
            print("PlaceID is available")
            removeButton.setTitle("Remove", for: .normal)
            removeButton.backgroundColor = Constants.Colors.purple
            removeButton.layer.borderColor = UIColor.white.cgColor
            removeButton.layer.borderWidth = 1.0
            removeButton.layer.cornerRadius = 2.0
            
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
    
    @IBAction func unwindToPopupCollection(_ segue: UIStoryboardSegue) {
        typesButton.titleLabel?.text = selectedType
        listNearbyPlaces()
        collectionView.reloadData()
    }
    
    func listNearbyPlaces() {
        
        typesButton.titleLabel?.text = selectedType
        activityIndicator.startAnimating()
        
        placesList.removeAll()
        
        let keyword = selectedType.replacingOccurrences(of: " ", with: "+")
        print(keyword)
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat!),\(long!)&radius=20000&keyword=\(keyword)&key=\(Constants.APIKey.web)")
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
                    if max >= 0 {
                        for count in 0...max {
                            self.placesList.append( Location(json: json["results"][count], setImage: true, collectionView: self.collectionView) )
                            print("Appended: \(json["results"][count]["name"].stringValue)")
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                self.present(Constants.Error.errorController, animated: true, completion: nil)
                print("Error: \(error.localizedDescription)")
                
            }
            
            
        }
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removePressed(_ sender: UIButton) {
        Answers.logCustomEvent(withName: "RemovedMarker", customAttributes: nil)
        performSegue(withIdentifier: "removeMarker", sender: self)
    }
    
    @IBAction func typesPressed(_ sender: Any) {
        present(typeAlertController, animated: true)
    }
    
}

extension PopupCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectPlaceCell", for: indexPath) as! PlaceCollectionViewCell
        cell.setLocation(to: placesList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlace = placesList[indexPath.row]
        performSegue(withIdentifier: "selectionMade", sender: self)
    }
}
