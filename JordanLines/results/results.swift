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



 class results: UIViewController {

static var itinerariescount = Int()
    
    struct leg {
        var mode = String()
        var fromname = String()
        var fromlat = Float()
        var fromlon = Float()
        var fromindex = Int()

        var departure = Int()
        var arrival = Int()
        
        var toname = String()
        var tolat = Float()
        var tolon = Float()
        var toindex = Int()
        
        var polyline = String()
        var duration = Int()
        var distance = Int()
        var routeId = String()
        var routeShortName = String()
        var routeLongName = String()
        var price = Int()
        var waittime = Int()

    }
    
    struct itinerary {
        var legn = [leg()]
        var totaltime = Int()
        var totalprice = Int()
        
    }
    static var itinerariesarr : [itinerary] = []
    


    @IBOutlet weak var itinerariesCollectionview: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name:NSNotification.Name(rawValue: "reloaddata"), object: nil)
        
       
      
        
//        let block = Async.background {
//            // Do stuff
//
//
//
//            var i = 1
//            while i <= 10 {
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                    print(i)
//                    i = i + 1
//                })
//
//            }
//
//
//        }
//
//        // Do other stuff
//
//
//        block.wait()
//        print(7)
//
//
//
//
        
        
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "taskQueue")
//        let dispatchSemaphore = DispatchSemaphore(value: 0)
//
//        dispatchQueue.async {
//            var i = 1
//                        while i <= 10 {
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                                print(i)
//                                i = i + 1
//                            })
//        dispatchSemaphore.signal()
//
//                        }
//        dispatchSemaphore.wait()
//
//
//
//        }
        

   }
        
        
        
    
    
    @objc func reload(){
        itinerariesCollectionview.reloadData()
    }
    class func getroutes(from:CLLocationCoordinate2D,to:CLLocationCoordinate2D) {
        var db: Firestore!
        // [START setup]
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings

        let busRef = db.collection("Stops")
        
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "taskQueue")
        let dispatchSemaphore = DispatchSemaphore(value: 0)

        
        // here we set the https parameters object
        var parameters = [
            "routerId": "routerIddefault",
            "maxWalkDistance": "2000",
            "mode":"WALK,TRANSIT",
            "cutoffSec":"3600",
            "fromPlace":"32.02137, 35.84421",
            "toPlace":"31.99445, 35.91961"]
      //  parameters["fromPlace"] = String(from.latitude) + "," + String(from.longitude)
      //  parameters["toPlace"] = String(to.latitude) + "," + String(to.longitude)
        
        // here we do the request and handle the response with Swifty Json library.
        Alamofire.request("http://jorlines.com:5000/api/plan", parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                // print("JSON: \(JSON(json)["plan"])") // serialized json response
                // return an array of possible ways
                let itineraries = JSON(json).arrayValue
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
        
        var imgarray = [cell.img1,cell.img2,cell.img3,cell.img4,cell.img5,cell.img6]
        var modearray = [cell.mode1,cell.mode2,cell.mode3,cell.mode4,cell.mode5,cell.mode6]
        var timearr = [cell.time1,cell.time2,cell.time3,cell.time4,cell.time5,cell.time6]

//        for img in imgarray {
//            img?.isHidden = true
//        }
//        for mode in modearray {
//            mode?.isHidden = true
//        }
//        for time in timearr {
//            time?.isHidden = true
//        }
        
        
        var cellitinerary = results.itinerariesarr[indexPath.item]
        
        var celllegs = cellitinerary.legn
        
        
        
        

        var mytime = Int(NSDate().timeIntervalSince1970/1000)
        var waitingtime = 0
       
        
        
        
        
        
        
        
        
        
//        cell.myLabel.text = finalarrayn[indexPath.item]
//        if indexPath.item < 7+self.emptyspacesarrn.count {
//            cell.isUserInteractionEnabled=false
//        }
//        cell.cellview.isHidden = true
//        cell.MonthLabel.text = ""
//        if indexPath.item == 7 + emptyspacesarrn.count {
//
//            cell.MonthLabel.text = monthsnameArr[currentmonth-1]
//        }
//        if indexPath.item == 7+emptyspacesarrn.count + currentmontharrayn.count {
//            cell.MonthLabel.text = monthsnameArr[month-1]        }
//        cell.cellview.layer.cornerRadius = 14
//        if indexselected == indexPath.item && indexselected != 0 {
//            cell.cellview.isHidden = false
//            cell.myLabel.textColor = UIColor.white
//            cell.MonthLabel.textColor = UIColor.white
//        }
        
        return cell
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // hide the old cell
//        var oldpath = IndexPath(item: indexselected, section: 0)
//
//        if indexselected != 0 {
//            let oldcell : CollectionViewCell = collectionView.cellForItem(at: oldpath)! as! CollectionViewCell
//            oldcell.cellview.isHidden = true
//            oldcell.myLabel.textColor = UIColor.black
//            oldcell.MonthLabel.textColor = UIColor.black
//        }
        
        
        
//        let cell : CollectionViewCell = collectionView.cellForItem(at: indexPath)! as! CollectionViewCell
//
//        indopath = indexPath.item
//        print(indopath)
//        self.indexselected = indopath
//        print(indexPath.item)
//        cell.cellview.isHidden = false
//        cell.myLabel.textColor = UIColor.white
//        cell.MonthLabel.textColor = UIColor.white
//
//        // to activate button
//        sharedobject.upatedateselection ()
//
//
//
//
//
//
//        print(indexPath.item)
//

//    }

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

