import UIKit
import RealmSwift

class ViewController: UIViewController {
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let bigNum = BN_new()
//        let prime = BN_generate_prime(bigNum,16,0,nil,nil,nil,nil)
//        print("PRIME INFO", prime, prime.dynamicType)
//        return UInt32(5)
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