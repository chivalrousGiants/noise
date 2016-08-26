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
        pCreate()
        
        
        
    }
    
    func generateRandomPrime () -> UnsafeMutablePointer<bignum_st> {
        let bigNum = BN_new()
        let prime = BN_generate_prime(bigNum,16,0,nil,nil,nil,nil)
        //print("PRIME INFO as unsafeMutablePointer--16 bits", prime, prime.dynamicType)
        return prime
    }
        func pCreate () -> bignum_st {
          return generateRandomPrime().memory
            //let aRandomInt = arc4random_uniform(100) + 1;
            //return UInt32(aRandomInt)
        }
    
}
