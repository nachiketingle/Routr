//
//  MapViewController.swift
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
import AlamofireImage
import AlamofireNetworkActivityIndicator
import SwiftyJSON

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    
    var count: Int = 0;
    var destinationList: [Location]?
    
    let APIKey = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    let APIKeyDir = "AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8"
    
    override func viewDidLoad() {
        
        print("Started to load")
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: 48.8566,
                                              longitude: 2.3522,
                                              zoom: zoomLevel)
        
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Creates current location marker (blue dot)
        mapView.isMyLocationEnabled = true
        
        print("Normal view stuff works.")
        
        if let destinations = destinationList {
            currentLocation = locationManager.location
            let lat = locationManager.location?.coordinate.latitude
            let long = locationManager.location?.coordinate.longitude
            
            //let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(lat!),\(long!)&destination=place_id:\(destinations[0].placeID)&waypoints=place_id:\(destinations[1].placeID)&key=\(APIKeyDir)")
            
            var params: [String : String] = [:]
            
            if !destinations.isEmpty {
                
                params["origin"] = "\(lat!),\(long!)"
                params["destination"] = "place_id:\(destinations[0].placeID)"
                
                if destinations.count > 1 {
                    var waypoints: String = "optimize:true"

                    for count in 1...destinations.count-1 {
                        waypoints.append("|place_id:\(destinations[count].placeID)")
                    }
                    params["waypoints"] = waypoints
                }
                params["key"] = APIKeyDir
            }
            
            //print("Place ID: \(destinations[0].placeID)")
            //print("URL is made: \(url!)")
            var points: String = ""
            //Alamofire.request(url!).validate().responseJSON() { (response) in
            //place_id:\(destinations[1].placeID)
            //["origin":"\(lat!),\(long!)", "destination":"place_id:\(destinations[0].placeID)", "waypoints":"" , "key":"\(APIKeyDir)"]
            Alamofire.request("https://maps.googleapis.com/maps/api/directions/json", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil) .validate().responseJSON() { (response) in
                
                //print("URL works")
                
                switch response.result {
                    
                case .success:
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print("This was successful!")
                        print("JSON Status is : \(json["status"])")
                        print("JSON error: \(json["error_message"])")
                        print("Summary: \(json["routes"][0]["summary"])")
                        print("Overview_polyline: \(json["routes"][0]["overview_polyline"]["points"])")
                        points = json["routes"][0]["overview_polyline"]["points"].stringValue
                        
                        
                        let path = GMSMutablePath(fromEncodedPath: points)
                        let route = GMSPolyline(path: path)
                        route.strokeWidth = 3.0
                        route.strokeColor = .init(red: 0, green: 0, blue: 1, alpha: 0.5)
                        route.map = self.mapView
                        
                        for place in destinations {
                            let marker = GMSMarker(position: place.coord)
                            marker.title = place.name
                            marker.snippet = place.address
                            marker.map = self.mapView
                        }
                        
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        }
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = false
        
        super.viewDidLoad()
        print("Finished loading")
    }
    
    @IBAction func unwindToMapViewController(_ segue: UIStoryboardSegue) {
        
        mapView.clear()
        
        if selectedPlace != nil {
            let marker = GMSMarker(position: (self.selectedPlace?.coordinate)!)
            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
        }
        
        //listLikelyPlaces()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPlacesList" {
                if let nextViewController = segue.destination as? PlaceViewController {
                    listLikelyPlaces()
                    nextViewController.likelyPlaces = likelyPlaces
                    //print("LikelyPlaces has been passed: \(likelyPlaces)")
                }
            } 
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //print("Location \(location)")
        
        let camera  = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        //print("Count is \(count)")
        //count += 1
        //listLikelyPlaces()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access restricted")
        case .denied:
            print("User denied access to this location")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status is not determined")
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.startUpdatingLocation()
        print("Error: \(error.localizedDescription)")
    }
    
    
    
    func listLikelyPlaces() {
        likelyPlaces.removeAll()
        
        placesClient.currentPlace (callback:{ (placeLikelihoods, error) -> Void in
            if let error = error {
                print("Current place error: \(error.localizedDescription)")
                return
            }
        
            if let likelihoodList = placeLikelihoods {
                //print("Starting to add places")
                self.count = 0
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    //print("This place was added: \(place.name)")
                    self.likelyPlaces.append(place)
                    self.count += 1
                }
                print("Finished adding places: \(self.count)")
            }
            
        })
        
    }
    
}
