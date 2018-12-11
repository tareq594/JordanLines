//
//  LineSetUp.swift
//  JordanLines
//
//  Created by Tareq Sanabra on 11/28/18.
//  Copyright © 2018 Tareq Sanabra. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import SwiftyJSON
import GoogleMaps
import GooglePlaces
import Firebase




class LineSetUp: UIViewController {
    
    var locationManager:CLLocationManager!
    var ismaploaded = false
    var searchedfield = "from"
    let frommarker = GMSMarker()
    let tomarker = GMSMarker()
    var isfromplaceactive = false
    var istoplaceactive = false
    var fromlocationCoordinates = CLLocationCoordinate2D()
    var tolocationCoordinates = CLLocationCoordinate2D()
    var isfromexist = false
    var istoexist = false
    var polyarrs = [JSON]()
    var issearched = false
    var db: Firestore!
    var stopdic = [String:String]()
    
    class stop {
        var name = String()
        var lat = CLLocationDegrees()
        var long = CLLocationDegrees()
            }
    var stotest = [Dictionary<String,String>]()
    
    var stops = Array<stop>()
    var stopsd = [Dictionary<String,String>]()
    
    
    


    @IBOutlet weak var Gmap: GMSMapView!
    
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
    
    
    // line info elements
    
    @IBOutlet weak var linename: UITextField!
    @IBOutlet weak var bustype: UITextField!
    @IBOutlet weak var routeDescription: UITextField!
    
    
    
    // search route button elsements
    
    @IBOutlet weak var searchRouteView: UIView!
    
    
    @IBOutlet weak var SearchButtonOutlet: UIButton!
    @IBAction func SearchRouteButton(_ sender: Any) {
        
        if issearched{
            SearchButtonOutlet.setTitle("Search Route", for: .normal)
            issearched = false
            var koko = ["stop2": "33.66,35.00" , "stop1":"33.66,34.99"]
            
            var data = [Dictionary<String,Any>]()
            data.append(["name":linename.text!,"stops":stopsd])
            
            
            print(JSON(data))
            
            
            
            
        } else {
            issearched = true
            SearchButtonOutlet.setTitle("Confirm", for: .normal)
        Gmap.camera = GMSCameraPosition.camera(withLatitude:fromlocationCoordinates.latitude , longitude:fromlocationCoordinates.longitude , zoom: 16)
        
        let parameters = [
//            "from": String(fromlocationCoordinates.latitude) + ", " + String(fromlocationCoordinates.longitude),
//            "to": String(tolocationCoordinates.latitude) + ", " + String(tolocationCoordinates.longitude)
            "from": "31.98266, 35.83332",
            "to": "31.97347, 35.83896"
        ]
        
        Alamofire.request("http://jorlines.com:5000/api/plotstops",parameters:parameters).responseString { response in
            let polyline = response.value!
            print(polyline)
            let polylineparameters = [
                "polyline": polyline,]
            Alamofire.request("http://api.khutoutna.gov.jo/decode", parameters: polylineparameters).responseJSON { response in
                if let json = response.result.value {
                    let polyarr = JSON(json).arrayValue
                    self.handlepolyarr(polyarr: polyarr)
                }
            }
            
        }
        }
    }

    
    
    var timer = Timer()
    var counter = 5

    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self,   selector: (#selector(LineSetUp.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if counter == 0 {
            timer.invalidate()
        } else {
    
        var bounds = GMSCoordinateBounds()
                        let lat = polyarrs[polyarrs.count-counter]["lat"].doubleValue
                        let lon = polyarrs[polyarrs.count-counter]["lon"].doubleValue
                        let pointmarker = GMSMarker()
                        pointmarker.map = self.Gmap
                        pointmarker.position.latitude = lat
                        pointmarker.position.longitude = lon
                        bounds = bounds.includingCoordinate(pointmarker.position)
            
            if counter == 1 {
                let polyparameters = [
                    "routerId": "routerIddefault",
                    "maxWalkDistance": "2000",
                    "mode":"WALK,TRANSIT",
                    "cutoffSec":"3600",
                    "fromPlace": (String(lat) + "," + String(lon)),
                    "toPlace":String(tolocationCoordinates.latitude) + ", " + String(tolocationCoordinates.longitude)]
                Alamofire.request("http://otp.khutoutna.gov.jo:8080/otp/routers/default/plan", parameters: polyparameters).responseJSON { response in
                    
                    if let json = response.result.value {
                        var stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][0]["from"]["name"].stringValue
                        if stopcreatedname == "Origin"{
                            stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][1]["from"]["name"].stringValue
                        }
                        
                        print(stopcreatedname)
//                        var mystop = stop()
//                        mystop.name = stopcreatedname
//                        mystop.lat = lat
//                        mystop.long = lon
//                        self.stops.append(mystop)
                        if stopcreatedname != ""{
                        self.stopsd.append(["name":stopcreatedname,"latlon":String(lat)+","+String(lon)])
                        }}
                }
                
            } else {
                        let polyparameters = [
                            "routerId": "routerIddefault",
                            "maxWalkDistance": "2000",
                            "mode":"WALK,TRANSIT",
                            "cutoffSec":"3600",
                            "fromPlace": (String(lat) + "," + String(lon)),
                            "toPlace": String(fromlocationCoordinates.latitude) + "," + String(fromlocationCoordinates.longitude)]
                        Alamofire.request("http://otp.khutoutna.gov.jo:8080/otp/routers/default/plan", parameters: polyparameters).responseJSON { response in
            
                            if let json = response.result.value {
                                var stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][0]["from"]["name"].stringValue
                                if stopcreatedname == "Origin"{
                                    stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][1]["from"]["name"].stringValue
                                }
                                print(stopcreatedname)
                                var mystop = stop()
//                                mystop.name = stopcreatedname
//                                mystop.lat = lat
//                                mystop.long = lon
//                                self.stops.append(mystop)
                                if stopcreatedname != ""{
                                    self.stopsd.append(["name":stopcreatedname,"latlon":String(lat)+","+String(lon)])
                                }

                            }
                        }
            }
            
            
            
            
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
                    Gmap.animate(with: update)
                    }
            counter = counter - 1
        }


    
    
    func handlepolyarr(polyarr : [JSON]){
     polyarrs = polyarr
     counter = polyarr.count
     var stopsd = [Dictionary<String,String>]()

        //stops = Array<stop>()
        
        runTimer()
        
        
//        var bounds = GMSCoordinateBounds()
//
//        for poly in polyarr {
//            let lat = poly["lat"].doubleValue
//            let lon = poly["lon"].doubleValue
//            let pointmarker = GMSMarker()
//            pointmarker.map = self.Gmap
//            pointmarker.position.latitude = lat
//            pointmarker.position.longitude = lon
//            bounds = bounds.includingCoordinate(pointmarker.position)
//
//            let polyparameters = [
//                "routerId": "routerIddefault",
//                "maxWalkDistance": "2000",
//                "mode":"WALK,TRANSIT",
//                "cutoffSec":"3600",
//                "fromPlace": (String(lat) + "," + String(lon)),
//                "toPlace":"31.994880000000002,35.919410000000006"]
//            Alamofire.request("http://otp.khutoutna.gov.jo:8080/otp/routers/default/plan", parameters: polyparameters).responseJSON { response in
//
//                if let json = response.result.value {
//                    var stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][0]["from"]["name"].stringValue
//                    if stopcreatedname == "Origin"{
//                        stopcreatedname = JSON(json)["plan"]["itineraries"][0]["legs"][1]["from"]["name"].stringValue
//                    }
//                    print(stopcreatedname)
//                }
//            }
//
//
//
//
//        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
//        Gmap.animate(with: update)
//        }
    }
    
    
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
//        let myGroup = DispatchGroup()
//        var are = [""]
//
//        for i in 0 ..< 5 {
//            myGroup.enter()
//
//            Alamofire.request("https://httpbin.org/get", parameters: ["foo": "bar"]).responseJSON { response in
//                print("Finished request \(i)")
//                are.append("\(i)")
//
//
//                myGroup.leave()
//            }
//        }
//
//        myGroup.notify(queue: .main) {
//            print("Finished all requests.")
//            print(are)
//        }
        
        
        
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        


        // Do any additional setup after loading the view.
        
        
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
        
        // set the map style from JSON file located in Styles folder.
        setMapStyle(mapview: Gmap,style: "LightMapStyle")

        determineMyCurrentLocation()

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
    func determineMyCurrentLocation() {
        // initialise Clllocation manager with it's delegate extension.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

}


// Location manager delegate extension starts to listen after determineMyCurrentLocation().
extension LineSetUp:CLLocationManagerDelegate {
    
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
       // to get device speed if negative object is not moving
        //print(manager.location?.speed)
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
// end of the Location Manager Delegate extension.


// begin of EdittextDelegate

extension LineSetUp:UITextFieldDelegate {
    
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

extension LineSetUp:GMSAutocompleteViewControllerDelegate {
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

extension LineSetUp:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if isfromplaceactive { frommarker.position = position.target }
        if istoplaceactive {tomarker.position = position.target}
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if isfromplaceactive {getaddress(location: position.target, textfield: fromplaceTextField)}
        if istoplaceactive {getaddress(location: position.target, textfield: ToTextField)}
        
    }
}

