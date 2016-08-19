//
//  WaitForConfirmationViewController.swift
//  noise
//
//  Created by Hannah Brannan on 8/18/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

class WaitForConfirmationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Attach listeners
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: Selector("handleCompletedKeyExchange"),
            name: "completedKeyExchange",
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        self.performSegueWithIdentifier("chatScreenSegue", sender: self)
    }

}
