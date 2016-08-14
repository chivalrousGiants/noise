import UIKit
import RealmSwift


class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var addFriendTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newFriend = User()
        newFriend.username = "ryanH"
        newFriend.lastname = "hansawa"
        newFriend.firstname = "ryan"
        
        let realm = try! Realm()
        try! realm.write{
            realm.add(newFriend)
        }
        let friends = realm.objects(User)
        print(friends)
    }

    @IBAction func addFriendTapped(sender: AnyObject) {
        let newFriend = User()
        newFriend.username = "MDLC"
        newFriend.lastname = "DeLaCruz"
        newFriend.firstname = "MDLC"
        
        let realm = try! Realm()
        try! realm.write{
            realm.add(newFriend)
        }
        let friends = realm.objects(User)
        print(friends)
    
   }


}
