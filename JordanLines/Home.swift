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
import Alamofire
import SwiftyJSON

class Home: UIViewController {
    
    var locationManager:CLLocationManager!
    var ismaploaded = false

    // connects the mapview from the storyboard.
    @IBOutlet weak var Gmap: GMSMapView!
    @IBOutlet weak var menu: UIBarButtonItem!
    // app view lifecycle => viewdidload.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // We set the Navigation bar to be Transparent, that gives the design more elegent taste.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        // The Side Menu settings.
        // to let the menue take effect.
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        //self.revealViewController()?.rearViewRevealWidth = 160
        
        // Take notifications from the side menue when it appears and disappears, so we can enable and disable
        // the map interaction accordingly. this is important to make the side menu gestures work.
        NotificationCenter.default.addObserver(self, selector: #selector(self.SideMenuAppear), name:NSNotification.Name(rawValue: "SideMenuAppear"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SideMenuDisappear), name:NSNotification.Name(rawValue: "SideMenuDisappear"), object: nil)

        // set the map style from JSON file located in Styles folder.
        setMapStyle(mapview: Gmap,style: "LightMapStyle")
        
        // sends HTTP request and receive the routes(Temp).
        getroutes()
    }
    
    // app view lifecycle => viewwillappear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // initialise Clllocation manager with it's delegate extension.
        determineMyCurrentLocation()
    }
    
   // see above when the function is called
   @objc func SideMenuAppear() {
    Gmap.isUserInteractionEnabled = false
    }
    
    // see above when the function is called
    @objc func SideMenuDisappear() {
    Gmap.isUserInteractionEnabled = true
    }

    
     // see above when the function is called
    func determineMyCurrentLocation() {
        // initialise Clllocation manager with it's delegate extension.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
}


 // see above when the function is called
    func getroutes() {
        // here we set the https parameters object
        let parameters = [
            "routerId": "routerIddefault",
            "maxWalkDistance": "2000",
            "mode":"WALK,TRANSIT",
            "cutoffSec":"3600",
            "fromPlace":"31.9637032,35.8746904",
            "toPlace":"32.0232583,35.8483421"]
        
        // here we do the request and handle the response with Swifty Json library.
        Alamofire.request("http://otp.khutoutna.gov.jo:8080/otp/routers/default/plan", parameters: parameters).responseJSON { response in
            if let json = response.result.value {
               // print("JSON: \(JSON(json)["plan"])") // serialized json response
            let itineraries = JSON(json)["plan"]["itineraries"].arrayValue
                print(itineraries.count)
            }
        }

}

func setMapStyle(mapview:GMSMapView!,style:String){
    do {
        // Set the map style by passing the URL of the local file.
        if let styleURL = Bundle.main.url(forResource: style, withExtension: "json") {
            mapview.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } else {
            print("Unable to find style.json")
        }
    } catch {
        print("One or more of the map styles failed to load. \(error)")
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
            let camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 14.0)
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
