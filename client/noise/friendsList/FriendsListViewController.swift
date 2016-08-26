import UIKit
import RealmSwift
import Locksmith
import CryptoSwift

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var friendsTableView: UITableView!
    let realm = try! Realm()
    
    // Must be 8 or 16 bytes (TODO: randomize for stronger encryption)
    let iv: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7]
    
    var friends : Results<Friend>?
    var clientMustInitiate = false
    var friendToChat : AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFriendsTable()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
        
        // on each page load query Redis for pending key exchanges
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
        getRecentConversation()
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
        // collect information about user & friend
        self.friendToChat = self.friends![indexPath.row]
        let friendID = Int((self.friendToChat["friendID"])!!.doubleValue)
        let userID = realm.objects(User)[0]["userID"]!
        let username = realm.objects(User)[0]["username"]!
        let friendname = self.friendToChat["username"]!
        
        let checkInitObj :[String:AnyObject] = ["friendID":friendID, "userID":userID, "username":username, "friendname":friendname!]
        let convoWithThisFriend = realm.objects(Conversation.self).filter("friendID = \(friendID)")

        if (convoWithThisFriend.isEmpty){
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
            self.performSegueWithIdentifier("chatScreenSegue", sender: self.friendToChat)
        }
    }
    
    ////// NOTIFICATION CENTER FUNCTIONS
    
    @objc func handleWait(notification: NSNotification) -> Void {
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
        let userInfo = notification.userInfo

        // Pass (userID, friendID) from friends_list_selection to label storage structures. Generate alice a, p, g, E.
        // Keychain (Locksmith) store; a, p, E in for later use / secrecy.
        // Redis call: pass IDs & p,g,E to redis for Bob to identify & access.
        let Alice = 666.alicify(userInfo!["userID"]!, friendID: userInfo!["friendID"]!)
        
        // wait for confirmation that Alice placed init info in redis
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
        
        let aliceSecret = UInt32(String(Locksmith.loadDataForUserAccount("noise:\(friendID!)")!["a_Alice"]!))

        var Alice :[String : AnyObject] = [:]
        Alice["friendID"] = friendID
        Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!,
            mySecret: aliceSecret!,
            p: p_computational!))
        
        // print("Alice's sharedSecret is", Alice["sharedSecret"]!)
        
        // Update Alice's KeyChain with newly computed sharedSecret
        666.aliceKeyChainPt2(Alice)

        initializeConvoObj(Int(friendID as! String)!)
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "KeyExchangeComplete", object: nil)
    }

    @objc func computeBob(notification:NSNotification) -> Void {
        let dhxInfo = notification.userInfo
        let Bob = 666.bobify(dhxInfo!["userID"]!, friendID: dhxInfo!["friendID"]!, E_Alice: dhxInfo!["eAlice"]!, p: dhxInfo!["pAlice"]!, g: dhxInfo!["gAlice"]!)
        
        // fired after Bob completes Part2BKeyExchange
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleBobComplete),
            name: "bobComplete",
            object: nil)
        
        SocketIOManager.sharedInstance.commencePart2KeyExchange(Bob)
        
        // TODO: Remove NS listener (complicated because we need listener for all pending keychanges)
    }
    
    @objc func handleBobComplete (notification:NSNotification) -> Void {
        // initialize Realm Conversation
        initializeConvoObj(Int(notification.userInfo!["friendID"] as! String)!)
        
        // TODO: Remove NS listener (complicated because we need listener for all pending keychanges)
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
                    newMessage.messageID = Int(message!["msgID"]!)!
                    
                    ////// Decrypt message
                    
                    // Convert NSData to Array<UInt8>
                    let nsData = message!["body"]!.dataFromHexadecimalString()
                    let count = nsData!.length / sizeof(UInt8)
                    var nsDataToUInt8Array = [UInt8](count: count, repeatedValue: 0)
                    nsData!.getBytes(&nsDataToUInt8Array, length: count * sizeof(UInt8))
                    // print("NSdata to UInt8Array", nsDataToUInt8Array)
                    
                    let key = String(Locksmith.loadDataForUserAccount("noise:\(messageObject["friendID"] as! String)")!["sharedSecret"]!)
                    // print("In FLVC sharedSecret for decryption of new messages:", key)
                    
                    var keyToUInt8Array = [UInt8](key.utf8)
                    
                    // pad keyToUInt8Array to 32 bytes
                    let initialLength = 32 - keyToUInt8Array.count
                    for _ in 1...initialLength {
                        keyToUInt8Array.append(0)
                    }

                    let decryptedUInt8Array = try! ChaCha20(key: keyToUInt8Array, iv: self.iv)!.decrypt(nsDataToUInt8Array)
                    print("decrypted UInt8 Array:", decryptedUInt8Array)

                    let decryptedMessage = String(data: NSData(bytes: decryptedUInt8Array), encoding: NSUTF8StringEncoding)!
                    print("decrypted message is:", decryptedMessage)
                    
                    newMessage.body = decryptedMessage
                    print("newMessage.body", newMessage.body)

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
        
        for conversation in allConversation {
            friendMessage["\(conversation.friendID)"] = conversation.largestMessageID
        }
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector (handleRetrievedMessages),
            name: "retrievedNewMessages",
            object: nil)
        
        SocketIOManager.sharedInstance.retrieveMessages(user, friends: friendMessage)
    }
    
    func initializeConvoObj(friendID: Int) {
        let convo = Conversation()
        convo.friendID = friendID
        
        try! realm.write {
            realm.add(convo)
            // grab any messages that Bob already sent Alice
            getRecentConversation()
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

// STRING TO NSDATA EXTENSION
extension String {
    /// Create `NSData` from hexadecimal string representation
    ///
    /// This takes a hexadecimal representation and creates a `NSData` object. Note, if the string has any spaces or non-hex characters (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    
    func dataFromHexadecimalString() -> NSData? {
        let data = NSMutableData(capacity: characters.count / 2)
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .CaseInsensitive)
        regex.enumerateMatchesInString(self, options: [], range: NSMakeRange(0, characters.count)) { match, flags, stop in
            let byteString = (self as NSString).substringWithRange(match!.range)
            var num = UInt8(byteString, radix: 16)
            data?.appendBytes(&num, length: 1)
        }
        
        return data
    }
}

