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

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var markerLocation: GMSPlace?
    var count: Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if let place = markerLocation {
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            marker.snippet = place.formattedAddress
            marker.map = mapView
        }
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        //mapView.isHidden = true
        
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
        
        listLikelyPlaces()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPlacesList" {
                if let nextViewController = segue.destination as? PlaceViewController {
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
        count += 1
        listLikelyPlaces()
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
                print("Starting to add places")
                for likelihood in likelihoodList.likelihoods {
                    let place = likelihood.place
                    //print("This place was added: \(place.name)")
                    self.likelyPlaces.append(place)
                }
                print("Finished adding places: \(self.count)")
            }
            
        })
        
    }
    
}
