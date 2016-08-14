import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Override username and password events
        usernameTextField.delegate = self;
        passwordTextField.delegate = self;
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        
        super.touchesBegan(touches, withEvent:event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == usernameTextField) {
            passwordTextField.becomeFirstResponder();
        } else if (textField == passwordTextField) {
            textField.resignFirstResponder();
            
            // Log in
            let userName = usernameTextField.text
            let userPassword = passwordTextField.text
            let user: [String: String] = ["username": userName!, "password": userPassword!]
            SocketIOManager.sharedInstance.signIn(user, handleSignIn: handleSignIn)
        }
        
        return true
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: self)
    }

    func handleSignIn(success: Bool) {
        if success {
            performSegueWithIdentifier("loginToFriendsListSegue", sender: self)
        } else {
            let alert:UIAlertController = UIAlertController(title: "Ooftah!", message: "username or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
            let action:UIAlertAction = UIAlertAction(title: "okee", style: UIAlertActionStyle.Default) { (a: UIAlertAction) -> Void in
                print("okee selected")
            }
            alert.addAction(action)
            self.presentViewController(alert, animated:true) { () -> Void in
                print("alert presented")
            }
        }
    }

}
