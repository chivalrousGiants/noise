import UIKit
import RealmSwift
import Locksmith

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var friendsTableView: UITableView!
    let realm = try! Realm()
    var friends : Results<Friend>?
    //var keyExchangeComplete = false
    var friendToChat : AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFriendsTable()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self

        // Attach listeners
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handlePursuingKeyExchange),
            name: "stillPursuingKeyExchange",
            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(computeBob),
            name: "computeBob",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleCompletedKeyExchange),
            name: "KeyExchangeComplete",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleBobComplete),
            name: "bobComplete",
            object: nil)

        getRecentConversation()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector (handleRetrievedMessages),
            name: "retrievedNewMessages",
            object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        updateFriendsTable()
    }
    
    func updateFriendsTable() {
        self.friends = realm.objects(Friend)
        self.friendsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let friend = self.friends![indexPath.row]
        cell.textLabel?.text = friend.username
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.friendToChat = self.friends![indexPath.row]

        //set-up to determine if chatInstance w/ specific friendID
        let friendID = Int((self.friendToChat["friendID"])!!.doubleValue)
        let convo = realm.objects(Conversation.self).filter("friendID = \(friendID)")

        //if no convo (already) exists, && if KEYCHAIN NOT WRITTEN YET && if ARE FRIENDS begin Diffie Hellman Key Exchange
        if (convo.isEmpty){
            //var aliceKeychain : [String:AnyObject]
                let aliceKeychain = Locksmith.loadDataForUserAccount("Alice_noise1:\(friendID)")
                print("aliceKeyChain is \(aliceKeychain)")
                //print("a_Alice is \(aliceKeychain["a_Alice"])")

               //if there is no value for a_alice, generate keychaing
            if (aliceKeychain == nil){
                let Alice = 666.alicify(realm.objects(User)[0]["username"]!, friendname: self.friendToChat.username!, friendID:friendID)
                SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)
            } else {
                var alicePkg = Locksmith.loadDataForUserAccount("Alice_noise1:\(friendID)")!
                alicePkg["username"] = realm.objects(User)[0]["username"]!
                alicePkg["friendname"] = self.friendToChat.username!   //////MAY NEED TO RETREIVE FRIEND ID
                
                SocketIOManager.sharedInstance.undertakeKeyExchange(alicePkg)
            }
        }
        else {
            //if is already established chat, segue to chatScreen
            self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
        }
    }
    
    /////////////////////////////////////////
    ////// NOTIFICATION CTR FUNCTIONS

    @objc func handlePursuingKeyExchange(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("segue user info from friendsCtrl \(userInfo)")
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
    }

    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        print("in handle complete")
        let dhxInfo = notification.userInfo
        let eBob_computational = UInt32(dhxInfo!["bobE"] as! String)
        let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
        let friendID = dhxInfo!["friendID"]
        var Alice :[String:AnyObject] = [:]
        let aliceSecret = UInt32(Locksmith.loadDataForUserAccount("Alice_noise1:\(friendID)")!["a_Alice"] as! String)
        print(aliceSecret)
        
        Alice["E"] = dhxInfo!["eAlice"]
        Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
        Alice["friendID"] = friendID
        666.aliceKeyChainPt2(Alice)
        
        //instantiate Realm Chat
        let convo = Conversation()
        self.performSegueWithIdentifier("chatScreenSegue", sender: self)
    }



    @objc func computeBob(notification:NSNotification) -> Void {
        let dhxInfo = notification.userInfo
        print("dhx info inside of compute bob [FRIENDSVIEWCONTROLLER] is \(dhxInfo!)")

        let Bob = 666.bobify(dhxInfo!["userID"]!, friendID: dhxInfo!["friendID"]!, E_Alice: dhxInfo!["eAlice"]!, p: dhxInfo!["pAlice"]!, g: dhxInfo!["gAlice"]!)
        
        SocketIOManager.sharedInstance.commencePart2KeyExchange(Bob)
    }
    
    @objc func handleBobComplete (notification:NSNotification) -> Void {
        print("hit BobComplete function")
        //instantiate Realm Chat
        let convo = Conversation()
        self.performSegueWithIdentifier("chatScreenSegue", sender: self)
    }
        
    @objc func handleRetrievedMessages(notification: NSNotification) -> Void {
        let retrievedMsgs = notification.userInfo!["messages"] as? NSArray
        
        for messageObject in retrievedMsgs! {
            if let messages = messageObject["messages"] as? NSArray {
                
                for message in messages {
                    let message = message as? Dictionary<String, String>
                    let newMessage = Message()
                    newMessage.sourceID = Int(message!["sourceID"]!)!
                    newMessage.targetID = Int(message!["targetID"]!)!
                    newMessage.createdAt = Int(message!["createdAt"]!)!
                    newMessage.body = message!["body"]!
                    newMessage.messageID = Int(message!["msgID"]!)!
                    
                    try! realm.write{
                        // convert NSString to doubleValue (float) then to Int in order to query FriendID in realm
                        let friendID = Int((messageObject["friendID"] as! NSString).doubleValue)
                        let conversationHistory = realm.objects(Conversation).filter("friendID = \(friendID)")[0]
                        conversationHistory["largestMessageID"] = Int(message!["msgID"]!)!
                        conversationHistory.messages.append(newMessage)
                    }
                }
            }
        }

        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // pass selected friend's object to ChatViewController on select.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chatScreenSegue" {
            let chatView = segue.destinationViewController as! ChatViewController
            chatView.friend = sender as! Friend
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let friendToDelete = self.friends![indexPath.row]
            try! realm.write {
                realm.delete(friendToDelete)
            }
            updateFriendsTable()
        }
    }
    
    func getRecentConversation() {
        let user = realm.objects(User)[0].userID
        let allConversation = realm.objects(Conversation)
        var friendMessage = [String: Int]()
        
        for convo in allConversation {
            friendMessage["\(convo.friendID)"] = convo.largestMessageID
        }
    
        SocketIOManager.sharedInstance.retrieveMessages(user, friends: friendMessage)
    }
    
    @IBAction func addFriendButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("addFriendSegue", sender: self)
    }
    
    @IBAction func chatsButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("chatsSegue", sender: self)
    }

    @IBAction func settingsButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("settingsSegue", sender: self)
    }
}
