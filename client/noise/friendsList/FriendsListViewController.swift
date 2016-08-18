import UIKit
import RealmSwift

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var friendsTableView: UITableView!
    let realm = try! Realm()
    var friends : Results<Friend>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFriendsTable()
        friendsTableView.dataSource = self
        friendsTableView.delegate = self
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
        //////////CODE INSIDE OF COMMENT -> POPUP INIT WHEN READY
        

                //compute DHX numbers
                let g_Alice = 666.gCreate()                    //TODO: explore: information loss from uint to string?
                let p_Alice = 666.pCreate()
                let a_Alice = 666.aAliceCreate()
                let E_Alice = 666.eCreate(g_Alice, mySecret: a_Alice, p: p_Alice)
    
                //insert a_Alice, E_Alice into user keychain

                //create an Alice obj that we will pass through sockets to the server
                var Alice : [String:AnyObject] = [:]
                Alice["username"] = realm.objects(User)[0]["username"]
                Alice["g"] = String(g_Alice)
                Alice["p"] = String(p_Alice)
                Alice["E"] = String(E_Alice)
                Alice["friendname"] = self.friends![indexPath.row].username
                SocketIOManager.sharedInstance.undertakeKeyExchange(Alice)

                //insert g_Alice, p_Alice, E_Alice into the Redis DB
                //insert Alice into Bob's pending.
                      ///TODO: determine whether to insert Bob into Alice's pending.
        
        ////////////////////////////////////////////////////////////////
        
        self.performSegueWithIdentifier("chatScreenSegue", sender: self)
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
