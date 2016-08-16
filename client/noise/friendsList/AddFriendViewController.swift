import UIKit
import RealmSwift



class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var addFriendTextField: UITextField!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addFriendTapped(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleAddFriendNotification),
            name: "reply for checkUser",
            object: nil)

        let friendToAdd = addFriendTextField.text

        // SEND: friendToAdd to server
        SocketIOManager.sharedInstance.addFriend(friendToAdd!)
        
    }
    
    @objc func handleAddFriendNotification(notification: NSNotification) -> Void {
        
        // friendToAdd is found in redis db
        if let userObj = notification.object {
            let newFriend = User()
            newFriend.firstname = userObj["firstname"] as! String
            newFriend.lastname = userObj["lastname"] as! String
            newFriend.username = userObj["username"] as! String
            
            try! realm.write {
                realm.add(newFriend)
            }
            
            performSegueWithIdentifier("backToFriendsListSegue", sender: self)
        } else {
            // friendToAdd was NOT found in redis db
            let alert:UIAlertController = UIAlertController(title: "Ooftah!", message: "no friend of that username exists", preferredStyle: UIAlertControllerStyle.Alert)
            let action:UIAlertAction = UIAlertAction(title: "bummer", style: UIAlertActionStyle.Default) { (a: UIAlertAction) -> Void in
                print("bummer button selected")
            }
            alert.addAction(action)
            
            self.presentViewController(alert, animated:true) { () -> Void in
                print("alert presented for unsuccessful addNewFriend")
            }
        }
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Testing
        let friends = realm.objects(User)
        print("Friends list:", friends)
        
    }

}
