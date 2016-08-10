import UIKit

class ViewController: UIViewController {
    //load login view
    @IBAction func loginButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("authSegue", sender: self)
    }
    
    @IBAction func friendsListButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("friendsListSegue", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    


}

