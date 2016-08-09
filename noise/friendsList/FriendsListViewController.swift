//
//  FriendsListViewController.swift
//  noise
//
//  Created by Michael DLC on 8/9/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

class FriendsListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addFriendButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("addFriendSegue", sender: self)
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
