import UIKit
import RealmSwift


class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var addFriendTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func addFriendTapped(sender: AnyObject) {
        let friendToAdd = addFriendTextField.text

        // SEND: friendToAdd to server
        SocketIOManager.sharedInstance.addFriend(friendToAdd!)
    }
    
    func performSegueToFriendsList() {
        performSegueWithIdentifier("backToFriendsListSegue", sender: self)
    }
    
    func presentNotFoundAlertMessage() {
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
}
