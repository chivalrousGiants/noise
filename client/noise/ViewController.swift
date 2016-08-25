import UIKit
import RealmSwift

class ViewController: UIViewController {
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {

//        let users = realm.objects(User)
//        if users.count == 0 {
//            self.performSegueWithIdentifier("authSegue", sender: self)
//        } else {
//            self.performSegueWithIdentifier("friendsListSegue", sender: self)
//        }
        //DELETE THIS WHEN UNCOMMENT ^^^^^^^
        self.performSegueWithIdentifier("authSegue", sender: self)
    }
    
    
}
