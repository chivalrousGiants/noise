//
//  ChatViewController.swift
//  noise
//
//  Created by Michael DLC on 8/17/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var CollectionView: UICollectionView!
    
    let messages = ["hello", "hi"]
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("herreeeee")
        
        self.CollectionView.dataSource = self
        self.CollectionView.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("where?")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SendCell",
            forIndexPath: indexPath) as! ChatCollectionViewCell
        
        //cell.receiveChatLabel.layer.cornerRadius = 5
        //cell.receiveChatLabel.layer.masksToBounds = true
        
        cell.sendChatLabel.layer.cornerRadius = 5
        cell.sendChatLabel.layer.masksToBounds = true
        
        cell.sendChatLabel.text = "HEY sdfdsgfdsgsfdgtgfdgdsrtsert the ovdsgsvherewafdcrertfsdcvfgvcxfdgvsdzsgxfdgsvzxvcd"
        
        return cell
    }
 

}
