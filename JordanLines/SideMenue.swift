//
//  SideMenue.swift
//  JordanLines
//
//  Created by Tareq Sanabra on 11/25/18.
//  Copyright © 2018 Tareq Sanabra. All rights reserved.
//

import UIKit

class SideMenue: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // initialise Clllocation manager with it's delegate extension.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SideMenuAppear"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SideMenuDisappear"), object: nil)

    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
