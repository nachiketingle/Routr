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
import Presentr

class MapViewController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.0
    
    var selectedPlace: Location?
    var selectMarkerLocation: CLLocationCoordinate2D?
    
    var count: Int = 0
    var destinations: [Location] = []
    var encodedPoints: String?
    var polylines: [String] = []
    var endPoint: Location!
    var updated = false
    
    let APIKey = "AIzaSyA0aS34EvGwGV8cpBck3zEUU6_8HKkfYuA"
    let APIKeyDir = "AIzaSyD1IwK5n262P-GQqNq-0pHbKTwPVPzscg8"
    let controller = PlaceViewController()
    let presenter = Presentr(presentationType: .popup)
    
    var selectMarker: GMSMarker! = nil
    var removeMarker: String?
    
    override func viewDidLoad() {
        
        print("Started to load MapViewController")
        
        //set up location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        currentLocation = locationManager.location
        
        //get current location and set up camera
        let lat = currentLocation?.coordinate.latitude
        let long = currentLocation?.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: lat!,
                                              longitude: long!,
                                              zoom: zoomLevel)
        
        directionsCall()
        
        //set up map view
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Creates current location marker (blue dot)
        mapView.isMyLocationEnabled = true
        
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = false
        mapView.delegate = self
        super.viewDidLoad()
        print("Finished loading")
    }
    
    @IBAction func unwindToMapViewController(_ segue: UIStoryboardSegue) {
        
        if let identifier = segue.identifier {
            if identifier == "removeMarker" {
                //iterate through all the places to find correct marker
                let num = destinations.count
                for count in 0...num {
                    if destinations[count].placeID == removeMarker {
                        destinations.remove(at: count)
                        break;
                    }
                }
                //check if marker was for final destination
                if endPoint.placeID == removeMarker {
                    if !destinations.isEmpty {
                        endPoint = destinations[0]
                    } else {
                        let camera = GMSCameraPosition.camera(withLatitude: (currentLocation?.coordinate.latitude)!,
                                                              longitude: (currentLocation?.coordinate.longitude)!,
                                                              zoom: zoomLevel)
                        mapView.animate(to: camera)
                    }
                }
                mapView.clear()
                directionsCall()
            } else if identifier == "selectionMade" {
                if let place = selectedPlace {
                    let marker = GMSMarker(position: place.coord)
                    marker.title = selectedPlace?.name
                    marker.snippet = selectedPlace?.address
                    marker.map = mapView
                    selectedPlace = nil
                    let camera = GMSCameraPosition.camera(withLatitude: place.lat,
                                                          longitude: place.long,
                                                          zoom: zoomLevel)
                    mapView.animate(to: camera)
                }
                
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toPlacesList" {
                if let nextViewController = segue.destination as? PlaceViewController {
                    print("Preparing to segue")
                    if let location = selectMarkerLocation {
                        nextViewController.lat = location.latitude
                        nextViewController.long = location.longitude
                        nextViewController.placeID = removeMarker!
                        selectMarkerLocation = nil
                    } else {
                        nextViewController.lat = currentLocation?.coordinate.latitude
                        nextViewController.long = currentLocation?.coordinate.longitude
                        nextViewController.placeID = nil
                    }
                    
                    print("Finished preperations")
                }
            } else if identifier == "cancel" {
                if let nextViewController = segue.destination as? HomeViewController {
                    nextViewController.destinations = self.destinations
                }
            }
        }
    }
    
    func setOverlays(){
        //add markers for every location added
        mapView.clear()
        print("Cleared the map")
        for place in self.destinations {
            let marker = GMSMarker(position: place.coord)
            marker.title = place.name
            marker.snippet = place.placeID
            marker.appearAnimation = .pop
            if endPoint.placeID == place.placeID {
                marker.icon = GMSMarker.markerImage(with: .green)
            } else {
                marker.icon = GMSMarker.markerImage(with: .blue)
            }
            
            marker.map = self.mapView
            print("Marker place: \(marker.title!)")
        }
        
        //set path
        var route: GMSPolyline, path: GMSMutablePath
        
        for point in polylines {
            //print("Encoded points made")
            //create a path from the encoded points
            path = GMSMutablePath(fromEncodedPath: point)!
            //print("Path made")
            route = GMSPolyline(path: path)
            //print("Route made")
            route.strokeWidth = 3.0
            route.strokeColor = .init(red: 0, green: 0, blue: 1, alpha: 0.3)
            route.map = self.mapView
        }
        print("Added route to mapView")
        
        //set bounds/animate to readjust mapView
        path = GMSMutablePath(fromEncodedPath: self.encodedPoints!)!
        let bounds = GMSCoordinateBounds.init(path: path)
        let position = self.mapView.camera(for: bounds, insets: UIEdgeInsets(top: 100, left: 50, bottom: 50, right: 50) )!
        self.mapView.animate(to: position)
    }
    
    func directionsCall() {
        
        
        if !destinations.isEmpty {
            //get current location
            let lat = currentLocation?.coordinate.latitude
            let long = currentLocation?.coordinate.longitude
            var params: [String : String] = [:]
            
            params["origin"] = "\(lat!),\(long!)"
            
            if endPoint == nil {
                endPoint = destinations[0]
            }
            navigationItem.prompt = "Destination: \(endPoint.name)"
            params["destination"] = "place_id:\(endPoint.placeID)"
            
            if destinations.count > 1 {
                var waypoints: String = "optimize:true"
                
                for count in 0...destinations.count-1 {
                    if endPoint.placeID != destinations[count].placeID {
                        waypoints.append("|place_id:\(destinations[count].placeID)")
                    }
                }
                params["waypoints"] = waypoints
            }
            params["key"] = APIKeyDir
            
            
            Alamofire.request("https://maps.googleapis.com/maps/api/directions/json", method: .get, parameters: params, encoding: URLEncoding.default, headers: nil) .validate().responseJSON() { (response) in
                
                //print("URL works")
                
                switch response.result {
                    
                case .success:
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        //print out statuc and error message if available
                        print("JSON Status is : \(json["status"])")
                        print("JSON error: \(json["error_message"])")
                        if json["status"] == "OK" {
                            
                            //receive points from json response
                            var legs = json["routes"][0]["legs"], legCount = legs.arrayValue.count
                            var steps: JSON, stepCount: Int
                            self.polylines.removeAll()
                            
                            //each leg
                            for count in 0...legCount-1 {
                                steps = legs[count]["steps"]
                                stepCount =  json["routes"][0]["legs"][count]["steps"].arrayValue.count
                                
                                //each step
                                for counter in 0...stepCount-1 {
                                    self.polylines.append(steps[counter]["polyline"]["points"].stringValue)
                                }
                            }
                            
                            //setting encoded points for polyline
                            self.encodedPoints = json["routes"][0]["overview_polyline"]["points"].stringValue
                            self.setOverlays()
                            
                        } else {
                            self.navigationItem.title = "No Available Route"
                        }
                    }
                    
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print("Marker tapped")
        
        for place in destinations {
            if place.placeID == marker.snippet {
                selectMarker = marker
                selectMarkerLocation = marker.position
                removeMarker = marker.snippet
                print("Have set marker location")
                performSegue(withIdentifier: "toPlacesList", sender: self)
                return true
            }
        }
        /*
         controller.lat = selectMarkerLocation?.latitude
         controller.long = selectMarkerLocation?.longitude
         presenter.blurBackground = true
         presenter.roundCorners = true
         presenter.dismissOnTap = true
         presenter.dismissOnSwipe = false
         customPresentViewController(presenter, viewController: controller, animated: true, completion: nil)
         */
        
        return false
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updated {
            return
        }
        let location: CLLocation = locations.last!
        //print("Location \(location)")
        
        let camera  = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
        
        updated = true
        //print("Count is \(count)")
        //count += 1
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
}
