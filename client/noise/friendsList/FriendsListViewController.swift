import UIKit
import RealmSwift
import Locksmith

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var friendsTableView: UITableView!
    let realm = try! Realm()
    var friends : Results<Friend>?
    var clientMustInitiate = false
    var friendToChat : AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFriendsTable()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        // on each page load query redis for pending key exchanges
        SocketIOManager.sharedInstance.checkForPendingKeyExchange(["userID": realm.objects(User)[0]["userID"]!]);

        // handle completion of key exchanges (cE 1 -> NE) triggered on pageload
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleCompletedKeyExchange),
            name: "KeyExchangeComplete",
            object: nil)
        
        // Bob responds to Alice's initiation of key exchange (cE 0 -> cE 0)
        // computes b_Bob, E_Bob, sharedSecret
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(computeBob),
            name: "computeBob",
            object: nil)
                
        // query redis for any new chat messages from friends
        // getRecentConversation()
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
        //collect informatino about user & friend
        self.friendToChat = self.friends![indexPath.row]
        let friendID = Int((self.friendToChat["friendID"])!!.doubleValue)
        let userID = realm.objects(User)[0]["userID"]!
        let username = realm.objects(User)[0]["username"]!
        let friendname = self.friendToChat["username"]!
        
        let checkInitObj :[String:AnyObject] = ["friendID":friendID, "userID":userID, "username":username, "friendname":friendname!]
        let convoWithThisFriend = realm.objects(Conversation.self).filter("friendID = \(friendID)")

        
        if (convoWithThisFriend.isEmpty){
            // check to see if if dhX process already initiated, handle results asynchronously
            print("friendClick -> checking to see if dhx initNeeded")
            
            // initiate dhKeyExchange after clicking friend's name
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(handleKeyExchangeInit),
                name: "init KeyExchange",
                object: nil)
            
            // dhKeyExchange already underway, segue to wait screen
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(handleWait),
                name: "wait",
                object: nil)

            SocketIOManager.sharedInstance.checkNeedToInitKeyExchange(checkInitObj)
            
        } else {
            // if chat exists, segue to chatScreen
            self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
        }
    }
    
    /////////////////////////////////////////
    ////// NOTIFICATION CENTER FUNCTIONS
    
    @objc func handlePursuingKeyExchange(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("segue user info from friendsCtrl \(userInfo)")
        
        
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "wait", object: nil)
    }
    
    @objc func handlePursuingKeyExchange(notification: NSNotification) -> Void {
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "completeKeyExchangeInitiation", object: nil)
    }
    
    @objc func handleKeyExchangeInit (notification:NSNotification) -> Void  {
        print("hit func target for alice1")
        
        let userInfo = notification.userInfo
        print("initiating keyExchange with dhxInfo: \(userInfo)")
        //alicify and call pursue key exchange.
         
        let Alice = 666.alicify(userInfo!["username"]!, friendname: userInfo!["friendname"]!, friendID: userInfo!["friendID"]!)
        print("asAlice \(Alice)")
        
        // wait for Alice to place init info in redis
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handlePursuingKeyExchange),
            name: "completeKeyExchangeInitiation",
            object: nil)

        SocketIOManager.sharedInstance.initiateKeyExchange(Alice)
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"init KeyExchange", object:nil)
    }

    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        let dhxInfo = notification.userInfo
        print("KX complete for both A and B with dhxInfo", dhxInfo)
        
        let eBob_computational = UInt32(dhxInfo!["bobE"] as! String)
        let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
        let friendID = dhxInfo!["friendID"]
        
        print("Alice's Locksmith", Locksmith.loadDataForUserAccount("noise:\(friendID)")!)
        
        let aliceSecret = UInt32(Locksmith.loadDataForUserAccount("noise:\(friendID)")!["a_Alice"] as! String)

        var Alice :[String:AnyObject] = [:]
        Alice["E"] = dhxInfo!["eAlice"]
        Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
        Alice["friendID"] = friendID
        666.aliceKeyChainPt2(Alice)
        
        // initialize convo object
        initializeConvoObj(Int(friendID as! String)!)
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "KeyExchangeComplete", object: nil)
    }

    @objc func computeBob(notification:NSNotification) -> Void {
        let dhxInfo = notification.userInfo
        print("dhx info inside of compute bob is \(dhxInfo!)")

        let Bob = 666.bobify(dhxInfo!["userID"]!, friendID: dhxInfo!["friendID"]!, E_Alice: dhxInfo!["eAlice"]!, p: dhxInfo!["pAlice"]!, g: dhxInfo!["gAlice"]!)
        
        // fired after Bob completes Part2BKeyExchange
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleBobComplete),
            name: "bobComplete",
            object: nil)
        
        SocketIOManager.sharedInstance.commencePart2KeyExchange(Bob)
        
        // Remove listener
        // TODO (complicated because we need listener for all pending keychanges)

    }
    
    @objc func handleBobComplete (notification:NSNotification) -> Void {
        print("hit BobComplete function")
        
        //instantiate Realm Chat
        initializeConvoObj(Int(notification.userInfo!["friendID"] as! String)!)
        
        // Remove listener
        // TODO (complicated because we need listener for all pending keychanges)
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

        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"retrievedNewMessages", object:nil)
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
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector (handleRetrievedMessages),
            name: "retrievedNewMessages",
            object: nil)
        
        SocketIOManager.sharedInstance.retrieveMessages(user, friends: friendMessage)
    }
    
    func initializeConvoObj(friendID: Int) {
        //instantiate Realm Chat
        let convo = Conversation()
        convo.friendID = friendID
        
        try! realm.write {
            realm.add(convo)
            // grab any messages that Bob already sent Alice
            getRecentConversation()
            // ideally chat screen should populate with messages grabbed from getRecentConversation()
            
            // segue to chatScreen if a boolean flag is true
        }

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
