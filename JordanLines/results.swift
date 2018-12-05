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


 class results: UIViewController {
static var koko = "soso"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    class func getroutes(from:CLLocationCoordinate2D,to:CLLocationCoordinate2D) {
        // here we set the https parameters object
        var parameters = [
            "routerId": "routerIddefault",
            "maxWalkDistance": "2000",
            "mode":"WALK,TRANSIT",
            "cutoffSec":"3600",
            "fromPlace":"31.9637032,35.8746904",
            "toPlace":"32.0232583,35.8483421"]
        parameters["fromPlace"] = String(from.latitude) + "," + String(from.longitude)
        parameters["toPlace"] = String(to.latitude) + "," + String(to.longitude)
        
        // here we do the request and handle the response with Swifty Json library.
        Alamofire.request("http://otp.khutoutna.gov.jo:8080/otp/routers/default/plan", parameters: parameters).responseJSON { response in
            if let json = response.result.value {
                // print("JSON: \(JSON(json)["plan"])") // serialized json response
                let itineraries = JSON(json)["plan"]["itineraries"].arrayValue
                print(itineraries)
                 print(itineraries.count)
            }
        }
    }

    
}

