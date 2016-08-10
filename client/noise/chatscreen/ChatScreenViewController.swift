//
//  ChatScreenViewController.swift
//  noise
//
//  Created by Michael DLC on 8/9/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

class ChatScreenViewController: UIViewController {
    //define dummy data
    var messageCollection : [[String: AnyObject]] = []
    var dummyDatum2 : [String: AnyObject] = ["userName": "MDLC", "createdAt": 2, "mssg": "yolo"]
    var dummyDatum3 : [String: AnyObject] = ["userName": "MDLC", "createdAt": 3, "mssg": "bro"]
    var dummyDatum4 : [String: AnyObject] = ["userName": "MDLC", "createdAt": 4, "mssg": "ohnono"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
