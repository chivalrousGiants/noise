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
        let stringfriendID = Int((self.friendToChat["friendID"])!!.doubleValue)
        let convo = realm.objects(Conversation.self).filter("friendID = \(stringfriendID)")

        //if no convo (already) exists, && KEYCHAIN NOT WRITTEN YET if && if ARE FRIENDS begin Diffie Hellman Key Exchange
        if (convo.isEmpty){
            var aliceKeychain : [String:AnyObject]
            do {
                aliceKeychain = Locksmith.loadDataForUserAccount("Alice_noise1")!
                print("aliceKeyChain is \(aliceKeychain)")
                print("a_Alice is \(aliceKeychain["a_Alice"])")
            } catch {
                print("could not retreive Alice keychain")
            }
            
            if (aliceKeychain["a_Alice"]  == nil){
                SocketIOManager.sharedInstance.undertakeKeyExchange(["username": realm.objects(User)[0]["username"]!, "friendname": self.friendToChat.username!])
            } else {
                let Alice = 666.alicify(realm.objects(User)[0]["username"]!, friendname: self.friendToChat.username!)
                SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)
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
        print("segue user info \(userInfo)")
         /*
         //pass dhX vals that Alice needs to access later into her keychain
         var AliceKeys : [String:AnyObject] = [:]
         AliceKeys["a_Alice"] = String(a_Alice)
         AliceKeys["p"] = String(p_Alice)
         AliceKeys["E"] = String(E_Alice)
         aliceKeyChainPt1(AliceKeys)
         */
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
    }

    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        print("in handle complete")
        let dhxInfo = notification.userInfo
        let eBob_computational = UInt32(dhxInfo!["bobE"] as! String)
        let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
        var Alice :[String:AnyObject] = [:]
        let aliceSecret = UInt32(Locksmith.loadDataForUserAccount("Alice_noise1")!["a_Alice"] as! String)
        print(aliceSecret)
        
        Alice["E"] = dhxInfo!["eAlice"]
        Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
        666.aliceKeyChainPt2(Alice)
        
        //instantiate Realm Chat
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
        self.performSegueWithIdentifier("loginToFriendsListSegue", sender: self)
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
