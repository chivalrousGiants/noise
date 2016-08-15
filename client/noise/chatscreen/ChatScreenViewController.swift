//
//  ChatScreenViewController.swift
//  noise
//
//  Created by Michael DLC on 8/9/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

//configure the roles that the ViewController will fulfill
class ChatScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    
    //outlets defined
    @IBOutlet weak var chatScreenTable: UITableView!
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var userTextInput: UITextField!  // change to tvMssgEditor?
    
    @IBOutlet weak var userInputBarConstraint: NSLayoutConstraint!
    
    //other internal vars defined
    var messageCollection : [[String: String]] = [] //eventually abstract this to DB
    let dummyDatum2 : [String: String] = ["userName": "MDLC", "createdAt": "2", "mssg": "yolo"]
    let dummyDatum3 : [String: String] = ["userName": "HB", "createdAt": "3", "mssg": "bro"]
    let dummyDatum4 : [String: String] = ["userName": "MDLC", "createdAt": "4", "mssg": "ohnono"]
    //timers?
    
    
////////////////////////////////////
////////FUNCTIONS ON LOAD
////////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up notifications: ( ~ listeners that broadcast mssg & metaData upon invocation)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidShowNotification), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardDidHideNotification), name: UIKeyboardDidHideNotification, object: nil)
        
        // Do any additional load-view setup.
        messageCollection.append(dummyDatum2)
        messageCollection.append(dummyDatum3)
        messageCollection.append(dummyDatum4)
//TODO: e.g., query server-DB for mssgData, sorted by createdAt (tbd by db choice)
        
        
        //config to display dummy data in table (codedTable will serve as source for tableView && ChatScreen-Table delegate relationship declared)
        chatScreenTable.dataSource = self
        chatScreenTable.delegate = self
        //userTextInput.delegate = self (already done in GUI)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
////////////////////////////////////
////////TABLE FUNCTIONS
////////////////////////////////////
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageCollection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(messageCollection[indexPath.row]["userName"]!): \(messageCollection[indexPath.row]["mssg"]!)"
        return cell
    }
    
    
////////////////////////////////////
////////USER INPUT View
////////////////////////////////////
    
    
    //TODO: move textField when enter textField to accomodate keybaord
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print(userTextInput.text)
    }
//TODO: fixxxx!!!
    func handleKeyboardDidShowNotification(notification: NSNotification){
        print("keyboardDidShow")
        //userInfo handles info passed on by other receiver objects in the notification chain
        //UIKeyboardFrame identifies the start frame of the keyboard in coordinates
        if let userInfo = notification.userInfo {
            print(userInfo)
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                print(keyboardFrame)
                userInputBarConstraint.constant = keyboardFrame.size.height + 44
                print(userInputBarConstraint)
                print(userInputBarConstraint.constant)
                view.layoutIfNeeded()
            }
        }
    }
    
    //TODO: fix
    //resign keyboard when submit text
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.userTextInput.resignFirstResponder()
        return true;
    }
    
    //move keyboard back
    //textFieldDidEndEditing
    
    func handleKeyboardDidHideNotification(notification: NSNotification) {
        userInputBarConstraint.constant = 44
        view.layoutIfNeeded()
    }
    
    
////////////////////////////////////
////////USER INPUT BUTTONS
////////////////////////////////////
    
    
    @IBAction func onMediaClick(sender: AnyObject) {
//TODO: (STRETCH) hookUp && change to Img
    }
    
//TODO: fix
    @IBAction func onSendClick(sender: AnyObject) {
//TODO: encrypt mssg
        //generate a createdAt timeStamp
        //add encrypted mssg to dataCollection
        messageCollection.append(["userName": "dynamic","mssg": userTextInput.text!, "createdAt":"5", "hasBeenDeleted":"0"])
        
        //emit socket encrypted_mssg to ChatServer
        SocketIOManager.sharedInstance.sendEncryptedChat(userTextInput.text!)
        //emit socket encrypted_mssg to ChatServer
        SocketIOManager.sharedInstance.sendNoisifiedChat(userTextInput.text!)
        
//TODO:[when receive] (stored) encyrpted_mssg decrypt && append to DOM
        let lastIdx = NSIndexPath(forRow: messageCollection.count-1, inSection: 0)
        chatScreenTable.beginUpdates()
        chatScreenTable.insertRowsAtIndexPaths([lastIdx], withRowAnimation: .Automatic)
        chatScreenTable.endUpdates()
        //alt: tbl.reloadData()
        
//TODO: noisify mssg and emit socket noisified_mssg to AnalyticsServer
        
        //drop keyboard
        userTextInput.resignFirstResponder()
    }
    
    
////////////////////////////////////
////////USER-FACING
////////////////////////////////////
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    //STRETCH: scroll to bottom
//    func scrollToBottom() {
//        let delay = 0.1 * Double(NSEC_PER_SEC)
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
//            if self.messageCollection.count > 0 {
//                let lastRowIndexPath = NSIndexPath(forRow: self.messageCollection.count - 1, inSection: 0)
//                self.chatScreenTable.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
//            }
//        }
//    }
    
////////////////////////////////////
////////SEGUE
////////////////////////////////////
    
//TODO: if userInfoButtonClicked, segue to userInfoViewController (also :TODO)
   // override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
   // }
}
