import UIKit
import RealmSwift

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
        getRecentConversation()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector (handleRetrievedMessages), name: "retrievedNewMessages", object: nil)
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
        //self.friendToChat = self.friends![indexPath.row]
        let friendToChat = friends![indexPath.row]
        //TEST
        // print(self.friendToChat)
        
        //let convo = realm.objects(Conversation.self).filter("friendID = \(self.friendToChat["friendID"])")
        //.filter("friendID = \(self.friendToChat["friendID"])")
        //print(convo)
        
        
        //realm if there is already established friend1/friend2 conversation
       // if (2 == 1){
           // let Alice = 666.alicify(realm.objects(User)[0]["username"]!, friendname: self.friendToChat.username!)
            //if not, query redis for status of the key exchange && wait for notification of keyExchangeCompletion
         //   SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)
      //  }
      //  else {
            //if is already established chat, segue to chatScreen
            self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
        //}
    }
    
    @objc func handlePursuingKeyExchange(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("segue user info \(userInfo)")
        keyExchangeComplete = false
        self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
        //sender: self
    }
    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        
        keyExchangeComplete = true
        self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
        //sender: self
    }
    @objc func handleRetrievedMessages(notification: NSNotification) -> Void {
        let retrievedMsgs = notification.userInfo
        print("printing retrievedmsg", retrievedMsgs)
        
        
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
        
        for friend in allConversation {
            friendMessage["\(friend.friendID)"] = friend.largestMessageID
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
