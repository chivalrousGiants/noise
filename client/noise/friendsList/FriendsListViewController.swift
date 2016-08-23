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

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleResumeKeyExchangeCheck),
            name: "resume KeyExchange",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleKeyExchangeInit),
            name: "init KeyExchange",
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
        //collect informatino about user & friend
        self.friendToChat = self.friends![indexPath.row]
        let friendID = Int((self.friendToChat["friendID"])!!.doubleValue)
        let userID = realm.objects(User)[0]["userID"]!
        let username = realm.objects(User)[0]["username"]!
        let friendname = self.friendToChat["friendname"]!
        let checkInitObj :[String:AnyObject] = ["friendID":friendID, "userID":userID, "username":username, "friendname":friendname!]
        let convoWithThisFriend = realm.objects(Conversation.self).filter("friendID = \(friendID)")

        
        if (convoWithThisFriend.isEmpty){
            //check to see if if dhX process already initiated, handle results asynchronously
            SocketIOManager.sharedInstance.checkNeedToInitKeyExchange(checkInitObj)
        } else {
            //if is already established chat, segue to chatScreen
            self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
        }
    }
    
    /////////////////////////////////////////
    ////// NOTIFICATION CTR FUNCTIONS

    @objc func handleKeyExchangeInit (notification:NSNotification) ->Void  {
        let userInfo = notification.userInfo
        print("initiating keyExchange with dhxInfo: \(userInfo)")
        //alicify and call pursue key exchange.
        
        let Alice = 666.alicify(userInfo!["username"]!, friendname: userInfo!["friendname"]!, friendID: userInfo!["friendID"]!)
        print("asAlice \(Alice)")

        SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)
    }
    
    @objc func handlePursuingKeyExchange(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("segue user info from friendsCtrl \(userInfo)")
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
    }
    
    @objc func handleResumeKeyExchangeCheck (notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("resuming as Bob or in later stage with \(userInfo)")
        var Bob : [String:AnyObject] = [:]
        Bob["username"] = userInfo!["username"]
        Bob["friendname"] = userInfo!["friendname"]
        
        SocketIOManager.sharedInstance.undertakeKeyExchange(Bob)
        
    }

    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        print("in handle complete")
        let dhxInfo = notification.userInfo
        let eBob_computational = UInt32(dhxInfo!["bobE"] as! String)
        let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
        let friendID = dhxInfo!["friendID"]
        var Alice :[String:AnyObject] = [:]
        let aliceSecret = UInt32(Locksmith.loadDataForUserAccount("noise:\(friendID)")!["a_Alice"] as! String)
        print(aliceSecret)
        
        Alice["E"] = dhxInfo!["eAlice"]
        Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
        Alice["friendID"] = friendID
        666.aliceKeyChainPt2(Alice)
        
        //instantiate Realm Chat
        Conversation()
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
        Conversation()
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
