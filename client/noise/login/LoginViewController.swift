import UIKit

class LoginViewController: UIViewController {

    @IBAction func signUpButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var userpasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signinButtonClicked(sender: AnyObject) {
        let userName = usernameTextField.text
        let userPassword = userpasswordTextField.text
        let user : [String:String] = ["username": userName!, "password": userPassword!]
        SocketIOManager.sharedInstance.signIn(user)
    }

}
