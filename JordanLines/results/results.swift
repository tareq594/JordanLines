//
//  results.swift
//  JordanLines
//
//  Created by Tareq Sanabra on 11/27/18.
//  Copyright © 2018 Tareq Sanabra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import Firebase
import PromiseKit
import Async
import GooglePlaces
import GoogleMaps



 class results: UIViewController {

static var itinerariescount = Int()
    
static var itinerariesarr = [JSON]()
    


    @IBOutlet weak var itinerariesCollectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name:NSNotification.Name(rawValue: "reloaddata"), object: nil)
   }
        
    
    @objc func reload(){
        itinerariesCollectionview.reloadData()
    }
    class func getroutes(from:CLLocationCoordinate2D,to:CLLocationCoordinate2D) {

        // here we set the https parameters object
        var parameters = [
            "routerId": "routerIddefault",
            "maxWalkDistance": "2000",
            "mode":"WALK,TRANSIT",
            "cutoffSec":"3600",
            "fromPlace":"31.97347, 35.83896",
            "toPlace":"31.9542, 35.83849"]
      //  parameters["fromPlace"] = String(from.latitude) + "," + String(from.longitude)
      //  parameters["toPlace"] = String(to.latitude) + "," + String(to.longitude)
        // here we do the request and handle the response with Swifty Json library.
        Alamofire.request("http://jorlines.com:5000/api/plan", parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                // print("JSON: \(JSON(json)["plan"])") // serialized json response
                // return an array of possible ways
                let itineraries = JSON(json).arrayValue
                print(itineraries)
                itinerariesarr = itineraries
                itinerariescount = itineraries.count
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloaddata"), object: nil)
            }
        }
    }
    
    
}

extension results:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.itinerariescount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itinerariesCell", for: indexPath) as! itinerariesCell
        
        cell.layer.cornerRadius = 8.0
        
        var imgarray = [cell.img1,cell.img2,cell.img3,cell.img4,cell.img5,cell.img6]
        var modearray = [cell.mode1,cell.mode2,cell.mode3,cell.mode4,cell.mode5,cell.mode6]
        var timearr = [cell.time1,cell.time2,cell.time3,cell.time4,cell.time5,cell.time6]

        for img in imgarray {
            img?.isHidden = true
        }
        for mode in modearray {
            mode?.isHidden = true
        }
        for time in timearr {
            time?.isHidden = true
        }
        
        
        let celllegs = results.itinerariesarr[indexPath.item].arrayValue
       // print(celllegs)
        
        var c = 0
        var duration = 0.0
        var isdescriped = false
        for cellleg in celllegs {
            // WE set things
            if cellleg["mode"] == "BUS"{
                print(c)
                // se the icon to bus
                if cellleg["busname"] == ""{
                    print("no bus")
                    cell.contentView.isHidden = true
                    cell.layer.backgroundColor = UIColor.clear.cgColor

                }
                imgarray[c]?.isHidden = false
                imgarray[c]?.image = UIImage(named: "busicon")
                modearray[c]?.isHidden = false
                modearray[c]?.text = cellleg["routeId"].stringValue
                timearr[c]?.isHidden = false
                let time = cellleg["duration"].doubleValue
                let timeinminutes = Int(time/60)
                timearr[c]?.text = String(timeinminutes) + " min"
                if !isdescriped {
                    isdescriped = true

                    let location = CLLocationCoordinate2DMake(cellleg["fromlat"].doubleValue, cellleg["fromlon"].doubleValue)
                    
                    var currentAddress = String()

                       let geocoder = GMSGeocoder()
                       geocoder.reverseGeocodeCoordinate(location) { (response, error) in
                        if let address = response?.firstResult() {
                            //  print(address)
                            let lines = address.lines! as [String]
                            currentAddress = lines.joined(separator: " ")
                            cell.closeststatus.text = "in " + String(timeinminutes) + " minutes from " + currentAddress
                        }
                }
                }
                
            } else {
                // it's walk
                print(c)
                
                imgarray[c]?.isHidden = false
                imgarray[c]?.image = UIImage(named: "walkicon")
                modearray[c]?.isHidden = false
                modearray[c]?.text = "Walk"
                timearr[c]?.isHidden = false
                let time = cellleg["duration"].doubleValue
                let timeinminutes = Int(time/60)
                timearr[c]?.text = String(timeinminutes) + " min"
                

                
                
            }
            duration = duration + cellleg["duration"].doubleValue + cellleg["waittime"].doubleValue
            c += 1
        }
        
        cell.esttime.text = String(Int(duration/60)) + " mins"
        
        

        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {


        let cell : itinerariesCell = collectionView.cellForItem(at: indexPath)! as! itinerariesCell
        
        print(indexPath.item)
        
        


        // to activate button






    }

//    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell : CollectionViewCell = collectionView.cellForItem(at: indexPath)! as! CollectionViewCell
//
//        cell.cellview.isHidden = true
//        cell.myLabel.textColor = UIColor.black
//        cell.MonthLabel.textColor = UIColor.black
//
//        print(indexPath)
        
        
//    }
//
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.frame.width/7 - 8
//
//        let height: CGFloat = width
//
//        return CGSize(width: width, height: height)
//    }
//
//
//    /// just layout for the collection view
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 8.0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 8.0
//    }
//
//
//
}

