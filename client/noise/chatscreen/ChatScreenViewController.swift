//
//  ChatScreenViewController.swift
//  noise
//
//  Created by Michael DLC on 8/9/16.
//  Copyright © 2016 Chivalrous Giants. All rights reserved.
//

import UIKit

//configure chatScreenVC: in addition to its default class, (DS)the table code herein will provide info needed to construct table view.
//ALSO, (Delegates) declares a relationship with (an)other obj(s) w/ which this classInstance can send and receive events e.g. --manage selections, configure section headings and footers, help to delete and reorder cells

class ChatScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    
    //outlets defined
    @IBOutlet weak var chatScreenTable: UITableView!
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var userTextInput: UITextField!  // change to tvMssgEditor?
    
    
    //other internal vars defined
    
    var messageCollection : [[String: String]] = []
    let dummyDatum2 : [String: String] = ["userName": "MDLC", "createdAt": "2", "mssg": "yolo"]
    let dummyDatum3 : [String: String] = ["userName": "HB", "createdAt": "3", "mssg": "bro"]
    let dummyDatum4 : [String: String] = ["userName": "MDLC", "createdAt": "4", "mssg": "ohnono"]
    //timers?
    
    
////////////////////////////////////
////////FUNCTIONS ON LOAD
////////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up notifications (broadcasts info w/in program) (NSNotifyCtR ~ notification dispatch table)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidShowNotification:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidHideNotification:", name: UIKeyboardDidHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
//TODO: query server-DB for mssgData

        
        messageCollection.append(dummyDatum2)
        messageCollection.append(dummyDatum3)
        messageCollection.append(dummyDatum4)
        
//TODO: sort messageCollection by createdAt (tbd by db choice)
        
        
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
           print("\(keyboardSize)")
            userInputView.frame.origin.y -= keyboardSize.height
        }
    }
    
    //TODO: fix
    //resign keyboard when submit text
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.userTextInput.resignFirstResponder()
        //for now, arbitrarily conform to func signature (return some Bool)
        return true;
    }
    
    //TODO: move keyboard back
    
    //textFieldDidEndEditing

    func handleKeyboardDidHideNotification(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            userInputView.frame.origin.y += keyboardSize.height
        }
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
        
        //add encrypted mssg to dataCollection
        messageCollection.append(["userName": "HB","mssg": userTextInput.text!, "createdAt":"5"])
        
        //emit socket encrypted_mssg to ChatServer
        SocketIOManager.sharedInstance.sendChat(userTextInput.text!)
        
//TODO:[when receive] (stored) encyrpted_mssg decrypt && append to DOM
        let lastIdx = NSIndexPath(forRow: messageCollection.count-1, inSection: 0)
        chatScreenTable.beginUpdates()
        chatScreenTable.insertRowsAtIndexPaths([lastIdx], withRowAnimation: .Automatic)
        chatScreenTable.endUpdates()
        
//TODO: noisify mssg and emit socket noisified_mssg to AnalyticsServer
        
        //quit keyboard
        userTextInput.resignFirstResponder()
    }
    
    //STRETCH: scroll to bottom
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
