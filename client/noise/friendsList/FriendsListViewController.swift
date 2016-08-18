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
        
        //fetch username from the selected cell
        let user = self.friends![indexPath.row]
        let username = user.username
        print("Username is \(username)")
        //get Alice's userId from redis
        //get Bob's userId from redis
        //query if user1/user2 has a chat history
           //YES >>> segue
           //NO >>>
                //compute DHX numbers
                let g_Alice = 666.gCreate()
                    print("her g is \(g_Alice)")
                let p_Alice = 666.pCreate()
                    print("her p is \(p_Alice)")
                let a_Alice = 666.aAliceCreate()
                    print("her a is \(a_Alice)")
                let E_Alice = 666.eCreate(g_Alice, mySecret: a_Alice, p: p_Alice)
                    print("her e is \(E_Alice)")
                //insert a_Alice into keychain
                //insert g_Alice, p_Alice, E_Alice into the Redis DB
                //insert Alice into Bob's pending.
                      ///???????????? insert Bob into Alice's pending. 
        
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
