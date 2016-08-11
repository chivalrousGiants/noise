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

class ChatScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    
    //outlets defined
    @IBOutlet weak var chatScreenTable: UITableView!
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var userTextInput: UITextField!
    //other internal vars defined
    var messageCollection : [[String: String]] = []
    
    
    
////////////////////////////////////
////////FUNCTIONS ON LOAD
////////////////////////////////////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up notifications (broadcasts info w/in program) (NSNotifyCtR ~ notification dispatch table)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidShowNotification:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardDidHideNotification:", name: UIKeyboardDidHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
        
        //define dummy data

        let dummyDatum2 : [String: String] = ["userName": "MDLC", "createdAt": "2", "mssg": "yolo"]
        let dummyDatum3 : [String: String] = ["userName": "HB", "createdAt": "3", "mssg": "bro"]
        let dummyDatum4 : [String: String] = ["userName": "MDLC", "createdAt": "4", "mssg": "ohnono"]
        messageCollection.append(dummyDatum2)
        messageCollection.append(dummyDatum3)
        messageCollection.append(dummyDatum4)
        
//TODO: sort messageCollection by createdAt (tbd by db choice)
        
        
        //config to display dummy data in table (codedTable will serve as source for tableView && ChatScreen-Table delegate relationship declared)
        chatScreenTable.dataSource = self
        chatScreenTable.delegate = self
        
        
        //Could declare delegate rel. w controller in code (but did so in GUI)
        //userTextInput.delegate = self
        
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
        cell.textLabel?.text = messageCollection[indexPath.row]["mssg"]
        return cell
    }
    
    
////////////////////////////////////
////////USER INPUT FUCNTIONS
////////////////////////////////////
    
    
    //TODO: move textField when enter textField to accomodate keybaord
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print(userTextInput.text)
    }
    
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
    @IBAction func onSendClick(sender: AnyObject) {
        //add text field entry to data
        messageCollection.append(["userName": "HB","mssg": userTextInput.text!, "createdAt":"5"])
        //emit socket mssg
        print(messageCollection)
        userTextInput.resignFirstResponder()
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
