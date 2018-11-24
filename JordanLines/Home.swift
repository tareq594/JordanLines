//
//  Home.swift
//  JordanLines
//
//  Created by Tareq Sanabra on 11/23/18.
//  Copyright © 2018 Tareq Sanabra. All rights reserved.

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class Home: UIViewController {
    
    var locationManager:CLLocationManager!
    var ismaploaded = false

    // connects the mapview from the storyboard.
    @IBOutlet weak var Gmap: GMSMapView!
    
    // app view lifecycle => viewdidload.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // app view lifecycle => viewwillappear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // initialise Clllocation manager with it's delegate extension.
        determineMyCurrentLocation()
    }
    
    func determineMyCurrentLocation() {
        // initialise Clllocation manager with it's delegate extension.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
}

// Location manager delegate extension starts to listen after determineMyCurrentLocation().
extension Home:CLLocationManagerDelegate {
    
    // Listen to location change.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation

        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        // manager.stopUpdatingLocation()
        
        // this is needed to load the map camera once the location is provided.
        if !ismaploaded {
            let camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 10.0)
            Gmap.camera = camera }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
        
       defaultmap()
    }
    
    // Listen for the ALLOW Location Access, and acts accordingly.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        case .restricted:
            defaultmap()
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            defaultmap()
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        default:
            break
        }
    }
    
    // this function set default map camera when location failed to be obtained
    func defaultmap(){
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        Gmap.camera = camera
    }
    
}
// end of the Location Manager Delegate extension.
