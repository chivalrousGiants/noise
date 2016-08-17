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
        // for testing, will be replaced with a real socket response
        let respondFromSocket = false
        // send friendToAdd to server via socket
            //if friendToAdd is found in redisdb
            if respondFromSocket {
                let newFriend = Friend(value: [
                    "username" : friendToAdd!,
                    "firstname" : "dummy",
                    "lastname" : "dummy",
                    "photo" : "optional",
                    "friendID": "userID"
                    ])
                try! realm.write{
                    realm.add(newFriend)
                }
                performSegueWithIdentifier("backToFriendsListSegue", sender: self)
            } else {
                 displayAlertMessage("username not found!")
        }
   }
    
    func displayAlertMessage(message: String) {
        let myAlert = UIAlertController(title:"Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:  nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

}
