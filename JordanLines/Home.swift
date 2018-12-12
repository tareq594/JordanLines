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
    var test = true
    var searchedfield = "from"
    let frommarker = GMSMarker()
    let tomarker = GMSMarker()
    var isfromplaceactive = false
    var istoplaceactive = false
    var fromlocationCoordinates = CLLocationCoordinate2D()
    var tolocationCoordinates = CLLocationCoordinate2D()
    var isfromexist = false
    var istoexist = false

    // connects the mapview from the storyboard.
    @IBOutlet weak var Gmap: GMSMapView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    
    // design elements
    // fromView elements
    @IBOutlet weak var fromDropMenu: UIView!
    @IBOutlet weak var FromChildView: UIView!
    @IBOutlet weak var fromsearchview: UIView!
    @IBOutlet weak var fromcurrentlocationView: UIView!
    @IBOutlet weak var fromPinFromMapView: UIView!
    @IBOutlet weak var fromparentviewheight: NSLayoutConstraint!
    
    @IBOutlet weak var fromplaceTextField: UITextField!
    
    
    @IBAction func fromSearchtextButton(_ sender: Any) {
        searchedfield = "from"
        getplace()
    }
    
    @IBAction func fromSearchIconButton(_ sender: Any) {
        searchedfield = "from"
        getplace()
    }
    
    @IBAction func fromCurrenPlace(_ sender: Any) {
        searchedfield = "from"
        getcurrentplace()
    }
    
    @IBAction func fromCurrentplaceIcon(_ sender: Any) {
        searchedfield = "from"
        getcurrentplace()
    }
    
    
    @IBAction func fromDoneTextButton(_ sender: Any) {
        if ToTextField.text == ""{
            ToTextField.becomeFirstResponder()
        } else {
            fromplaceTextField.resignFirstResponder()
        }
    }
    
    @IBAction func fromDoneIconButton(_ sender: Any) {
        if ToTextField.text == ""{
            ToTextField.becomeFirstResponder()
        } else {
            fromplaceTextField.resignFirstResponder()
        }
    }
    
    @IBOutlet weak var FromXbutoonOutlet: UIButton!
    @IBAction func fromXButton(_ sender: Any) {
        frommarker.map = nil
        fromplaceTextField.text = ""
        fromplaceTextField.resignFirstResponder()
        isfromexist = false
        FromXbutoonOutlet.isHidden = true
        searchRouteView.isHidden = true
    }
    
    
    // ToView elements
    @IBOutlet weak var ToChildView: UIView!
    @IBOutlet weak var ToSearchView: UIView!
    @IBOutlet weak var ToCurrentView: UIView!
    @IBOutlet weak var ToPinFromMapView: UIView!
    @IBOutlet weak var ToDropMenuView: UIView!
    @IBOutlet weak var ToParentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ToTextField: UITextField!
    
    
    @IBAction func Tosearchtextbutton(_ sender: Any) {
        searchedfield = "to"
        getplace()
    }
    @IBAction func TosearchIconButton(_ sender: Any) {
        searchedfield = "to"
        getplace()
    }
    
    @IBAction func toCurrentPlaceTextButton(_ sender: Any) {
        searchedfield = "to"
        getcurrentplace()
    }
    
    @IBAction func TocurrentplaceiconButton(_ sender: Any) {
        searchedfield = "to"
        getcurrentplace()
    }
    @IBAction func toDoneTextButton(_ sender: Any) {
        ToTextField.resignFirstResponder()
    }
    
    @IBAction func toDoneIconButton(_ sender: Any) {
        ToTextField.resignFirstResponder()
    }
    
    @IBOutlet weak var ToXbuttonOutlet: UIButton!
    
    @IBAction func ToXbutton(_ sender: Any) {
        tomarker.map = nil
        ToTextField.text = ""
        istoexist = false
        ToTextField.resignFirstResponder()
        ToXbuttonOutlet.isHidden = true
        searchRouteView.isHidden = true
    }
    
    // search route button elsements
    
    @IBOutlet weak var searchRouteView: UIView!
   
    
    @IBOutlet weak var SearchButtonOutlet: UIButton!
    @IBAction func SearchRouteButton(_ sender: Any) {
        results.getroutes(from: fromlocationCoordinates,to: tolocationCoordinates)
        resultsView.isHidden = false
    }
    
    // results View
    
    @IBOutlet weak var resultsView: UIView!
    
    @IBOutlet weak var resultsHeight: NSLayoutConstraint!
    
    // app view lifecycle => viewdidload.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // We set the Navigation bar to be Transparent, that gives the design more elegent taste.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        // set cornerradius.
        FromChildView.layer.cornerRadius = 6.0
        fromPinFromMapView.layer.cornerRadius = 6.0
        fromsearchview.layer.cornerRadius = 6.0
        fromcurrentlocationView.layer.cornerRadius = 6.0
        ToChildView.layer.cornerRadius = 6.0
        ToSearchView.layer.cornerRadius = 6.0
        ToCurrentView.layer.cornerRadius = 6.0
        ToPinFromMapView.layer.cornerRadius = 6.0
        SearchButtonOutlet.layer.cornerRadius = 2.0
        
        // by default the dropdown menues are hidden.
        hideFromDropMenu()
        hideToDropMenu()
        searchRouteView.isHidden = true

        
        fromplaceTextField.inputView = UIView()
        ToTextField.inputView = UIView()
        FromXbutoonOutlet.isHidden = true
        ToXbuttonOutlet.isHidden = true
        
        
        frommarker.icon = UIImage(named: "fromiconpin")
        tomarker.icon = UIImage(named: "finishflag")
        
        


        
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
        
        
        // results view swipe configs
        let downswipe = UISwipeGestureRecognizer(target: self, action: #selector(handleswipe(sender:)))
        downswipe.direction = .down
        let upswipe = UISwipeGestureRecognizer(target: self, action: #selector(handleswipe(sender:)))
        upswipe.direction = .up
        resultsView.addGestureRecognizer(downswipe)
        resultsView.addGestureRecognizer(upswipe)
        resultsView.isHidden = true
        
        
        
        determineMyCurrentLocation()

    }
    
    // app view lifecycle => viewwillappear.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // initialise Clllocation manager with it's delegate extension.
    }
    
    // handle results view swipes
    @objc func handleswipe (sender : UISwipeGestureRecognizer) {
        if sender.state == .ended{
            switch sender.direction{
            case .down:
                print("it's down")
            case .up:
                print("it's up")
            default:
                break
            }
        }
    }
    
   func getcurrentplace() {
    if searchedfield == "from"{
        if locationManager.location != nil {
            Gmap.camera = GMSCameraPosition.camera(withTarget: (locationManager?.location?.coordinate)!, zoom: 16.0)}
        frommarker.map = Gmap
    }
    if searchedfield == "to"{
        if locationManager.location != nil {
            Gmap.camera = GMSCameraPosition.camera(withTarget: (locationManager?.location?.coordinate)!, zoom: 16.0)}
        tomarker.map = Gmap
    }
    
    }
    
    func getplace(){
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        let currentmapcamera = Gmap.camera.target
        let neBoundsCorner = CLLocationCoordinate2D(latitude: currentmapcamera.latitude + 0.0161795,
                                                    longitude: currentmapcamera.longitude + 0.0331735)
        let swBoundsCorner = CLLocationCoordinate2D(latitude: currentmapcamera.latitude - 0.0161795,
                                                    longitude: currentmapcamera.longitude - 0.0331735)
        let bounds = GMSCoordinateBounds(coordinate: neBoundsCorner,
                                         coordinate: swBoundsCorner)
        
        autocompleteController.autocompleteBounds = bounds
        
        present(autocompleteController, animated: true, completion: nil)

        
    }

    
    func hideFromDropMenu() {
        // 1- hide dropmenue view and disable it
        fromDropMenu.isHidden = true
        // 2- set the hight of the from parent view to 49
        fromparentviewheight.constant = 49
    }
    
    func hideToDropMenu() {
        // 1- hide dropmenue view and disable it
        ToDropMenuView.isHidden = true
        // 2- set the hight of the from parent view to 49
        ToParentViewHeight.constant = 49
    }
    
    func showFromDropMenu() {
        // 1- hide dropmenue view and disable it
        fromDropMenu.isHidden = false
        // 2- set the hight of the from parent view to 49
        fromparentviewheight.constant = 152
    }
    
    func showToDropMenu() {
        // 1- hide dropmenue view and disable it
        ToDropMenuView.isHidden = false
        // 2- set the hight of the from parent view to 49
        ToParentViewHeight.constant = 152
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



// set mab style
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
            let camera = GMSCameraPosition.camera(withLatitude: (userLocation.coordinate.latitude), longitude: (userLocation.coordinate.longitude), zoom: 16.0)
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
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16.0)
        Gmap.camera = camera
    }
    
    func getaddress (location:CLLocationCoordinate2D,textfield:UITextField)  {
        let geocoder = GMSGeocoder()
        var currentAddress = String()
        geocoder.reverseGeocodeCoordinate(location) { (response, error) in
            if let address = response?.firstResult() {
                //  print(address)
                let lines = address.lines! as [String]
                 currentAddress = lines.joined(separator: " ")
                //print(currentAddress)
                textfield.text = currentAddress
    }
        }

    }
    
}
// end of the Location Manager Delegatem extension.

// begin of EdittextDelegate

extension Home:UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == fromplaceTextField{
            showFromDropMenu()
            if isfromexist {
                Gmap.camera = GMSCameraPosition.camera(withTarget:fromlocationCoordinates, zoom: 16.0)
            }
            frommarker.position = Gmap.camera.target
            frommarker.map = Gmap
             isfromplaceactive = true
            searchedfield = "from"
            getaddress(location: Gmap.camera.target, textfield: fromplaceTextField)
            FromXbutoonOutlet.isHidden = false
        }
        if textField == ToTextField {
            showToDropMenu()
            if istoexist {
                Gmap.camera = GMSCameraPosition.camera(withTarget:tolocationCoordinates, zoom: 16.0)
            }
            
            tomarker.position = Gmap.camera.target
            tomarker.map = Gmap
            istoplaceactive = true
            searchedfield = "to"
            getaddress(location: Gmap.camera.target, textfield: ToTextField)
            ToXbuttonOutlet.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == fromplaceTextField{
            hideFromDropMenu()
            isfromplaceactive = false
            let Cposition = Gmap.camera.target
            fromlocationCoordinates = Cposition
            if istoexist {
                searchRouteView.isHidden = false
            }
            isfromexist = true
            Gmap.camera = GMSCameraPosition.camera(withLatitude: Cposition.latitude - 0.0004, longitude: Cposition.longitude + 0.000422, zoom: 16.0)

        }
        if textField == ToTextField{
            hideToDropMenu()
            istoplaceactive = false
            let Cposition = Gmap.camera.target
            tolocationCoordinates = Cposition
            if isfromexist {
                searchRouteView.isHidden = false
            }
            istoexist = true
            Gmap.camera = GMSCameraPosition.camera(withLatitude: Cposition.latitude - 0.0004, longitude: Cposition.longitude + 0.000422, zoom: 16.0)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true;
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true;
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true;
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
   



}
// end of EdittextDelegate

// begin of google places Delegate

extension Home:GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // hoon m3naha 25tar place o rj3lna place // place.coordinate // place.name // place.formattedAddress
       // print(place.coordinate)
        Gmap.camera = GMSCameraPosition.camera(withTarget: place.coordinate, zoom: 16.0)
        dismiss(animated: true, completion: nil)
        if searchedfield == "from"{
            isfromexist = false
            fromplaceTextField.becomeFirstResponder()
        }
        if searchedfield == "to"{
            istoexist = false
            ToTextField.becomeFirstResponder()
        }
        

    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)

    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        if searchedfield == "from"{
            fromplaceTextField.becomeFirstResponder()
        }
        if searchedfield == "to"{
            ToTextField.becomeFirstResponder()
        }
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }

}

extension Home:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if isfromplaceactive { frommarker.position = position.target } 
        if istoplaceactive {tomarker.position = position.target}
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if isfromplaceactive {getaddress(location: position.target, textfield: fromplaceTextField)}
        if istoplaceactive {getaddress(location: position.target, textfield: ToTextField)}

    }
}
