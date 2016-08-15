import UIKit
import RealmSwift


class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var addFriendTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func addFriendTapped(sender: AnyObject) {
        
        let friendToAdd = addFriendTextField.text
        
        let newFriend = User()
        newFriend.username = friendToAdd!
        newFriend.lastname = "dummy"
        newFriend.firstname = "dummy"
        
        let realm = try! Realm()
        try! realm.write{
            realm.add(newFriend)
        }
        let friends = realm.objects(User)
        print(friends)
        
        performSegueWithIdentifier("backToFriendsListSegue", sender: self)
    
   }
}
