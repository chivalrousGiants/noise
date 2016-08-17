import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        // TODO: Change this to query our login state from Realm. If we're not logged in, show the intro/login view controller
        let loggedIn = false;
        
        if loggedIn {
            self.performSegueWithIdentifier("friendsListSegue", sender: self)
        } else {
            self.performSegueWithIdentifier("authSegue", sender: self)
        }
    }
    
    //    @IBAction func loginButtonClicked(sender: AnyObject) {
    //        self.performSegueWithIdentifier("authSegue", sender: self)
    //    }
    //
    //    @IBAction func friendsListButtonClicked(sender: AnyObject) {
    //        self.performSegueWithIdentifier("friendsListSegue", sender: self)
    //    }
    
}