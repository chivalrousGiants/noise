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
            name: "checkUser",
            object: nil)

        let friendToAdd = addFriendTextField.text
        
        // check if friendToAdd is already a friend
        if realm.objects(Friend).filter("username = '\(friendToAdd!)'").count != 0 {
            displayAlertMessage("you are already friends with \(friendToAdd!)")
        } else if friendToAdd! == "" {
            displayAlertMessage("please enter a username")
        } else {
            // SEND: friendToAdd to server
            SocketIOManager.sharedInstance.addFriend(friendToAdd!)
        }
    }
    
    @objc func handleAddFriendNotification(notification: NSNotification) -> Void {
        
        //print("friendObj", notification.userInfo)
        
        if let userObj = notification.userInfo {
            
            // insert new friend data in realm
            let newFriend = Friend()
            newFriend.firstname = userObj["firstname"] as! String
            newFriend.lastname = userObj["lastname"] as! String
            newFriend.username = userObj["username"] as! String
            newFriend.friendID = Int(userObj["userID"] as! String)!
            
            try! realm.write {
                realm.add(newFriend)
            }
            
            performSegueWithIdentifier("backToFriendsListSegue", sender: self)
        } else {
            // friendToAdd was NOT found in redis db
            displayAlertMessage("no friend of that username exists")
        }
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Testing
        //print("Friends list:", realm.objects(Friend))
        
    }
    
    func displayAlertMessage(message: String) {
        let alert = UIAlertController(title:"Ooftah!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action:UIAlertAction = UIAlertAction(title: "oops", style: UIAlertActionStyle.Default) { (a: UIAlertAction) -> Void in
            // print("oops button selected")
        }
        alert.addAction(action)
        
        self.presentViewController(alert, animated:true) { () -> Void in
            // print("alert presented for \(message)")
        }
    }
}
