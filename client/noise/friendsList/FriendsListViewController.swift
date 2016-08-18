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
        let friendToChat = self.friends![indexPath.row]
        self.performSegueWithIdentifier("chatScreenSegue", sender: friendToChat)
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
