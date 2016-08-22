import UIKit
import RealmSwift
import Locksmith

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var friendsTableView: UITableView!
    let realm = try! Realm()
    var friends : Results<Friend>?
    var keyExchangeComplete = false
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
            selector: #selector(handleCompletedKeyExchange),
            name: "KeyExchangeComplete",
            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(computeBob),
            name: "computeBob",
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
        //print(self.friendToChat)
        
        //let convo = realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])")
        //.filter("friendID = \(self.friendToChat["friendID"])")
        //print(convo)
        
        
        //realm if there is already established friend1/friend2 conversation
        if (0 == 0){
            let Alice = 666.alicify(realm.objects(User)[0]["username"]!, friendname: self.friendToChat.username!)
            //if not, query redis for status of the key exchange && wait for notification of keyExchangeCompletion
            SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)
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
        keyExchangeComplete = false
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
        //sender: self
        // Remove listener
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        print("in handle complete")
            /*
        let dhxInfo = notification.userInfo
        let eBob_computational = UInt32(dhxInfo!["eBob"] as! String)
        let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
        let aliceOnly = Locksmith.loadDataForUserAccount("noise")
        let aliceSecret =  UInt32(aliceOnly!["a_Alice"] as! String)
        let sharedSecret = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
        print(sharedSecret)
        //try Locksmith.saveData(["sharedSecret":sharedSecret], forUserAccount:"noise")
    */
        self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)

        // Remove listener
        //NSNotificationCenter.defaultCenter().removeObserver(self)

    }

    @objc func computeBob(notification:NSNotification) -> Int {
        let dhxInfo = notification.userInfo
        print("dhx info inside of compute bob [FRIENDSVIEWCONTROLLER] is \(dhxInfo)!")
        print(dhxInfo!["userID"])
        let Bob = 666.bobify(dhxInfo!["userID"]!, friendID: dhxInfo!["friendID"]!, E_Alice: dhxInfo!["eAlice"]!, p: dhxInfo!["pAlice"]!, g: dhxInfo!["gAlice"]!)

       // NSNotificationCenter.defaultCenter().removeObserver(self)
        SocketIOManager.sharedInstance.commencePart2KeyExchange(Bob)
        return 5
        //TODO: pass computed value directly into
        //1) keychain
        //2) encryption
        //3)
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
