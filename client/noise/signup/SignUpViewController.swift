import UIKit
import RealmSwift

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Override events
        firstnameTextField.delegate = self;
        lastnameTextField.delegate = self;
        usernameTextField.delegate = self;
        passwordTextField.delegate = self;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true);
        
        // Hide keyboard if user taps outside of the input field
        super.touchesBegan(touches, withEvent:event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstnameTextField {
            lastnameTextField.becomeFirstResponder()
        } else if textField == lastnameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
        
            textField.resignFirstResponder()
            
            // Attach listeners
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(handleSignUpNotification),
                name: "signup",
                object: nil)
            
            // Sign Up
            let firstname = firstnameTextField.text
            let lastname = lastnameTextField.text
            let userName = usernameTextField.text
            let userPassword = passwordTextField.text
            let user: [String: String] = [
                "firstname": firstname!,
                "lastname": lastname!,
                "username": userName!,
                "password": userPassword!
            ]
            
            SocketIOManager.sharedInstance.signUp(user)
        }
         return true
    }
    
    @objc func handleSignUpNotification(notification: NSNotification) -> Void {
        
        print("signUpObj", notification.userInfo)
        
        if let signUpObj = notification.userInfo {
            
            // insert user data in realm
            let newUser = User()
            newUser.firstname = signUpObj["firstname"] as! String
            newUser.lastname = signUpObj["lastname"] as! String
            newUser.username = signUpObj["username"] as! String
            newUser.userID = Int(signUpObj["userId"] as! String)!
            newUser.id = 0
            
            try! realm.write {
                realm.add(newUser, update:true)
            }
            
            performSegueWithIdentifier("signUpToFriendsListSegue", sender: self)
            
        } else {
            // username already taken, unsuccessful signup
            let alert:UIAlertController = UIAlertController(title: "Ooftah!", message: "Yoosername is already taken", preferredStyle: UIAlertControllerStyle.Alert)
            let action:UIAlertAction = UIAlertAction(title: "wat", style: UIAlertActionStyle.Default) { (a: UIAlertAction) -> Void in
                print("wat selected")
            }
            alert.addAction(action)
            self.presentViewController(alert, animated:true) { () -> Void in
                print("alert presented for unsuccessful signup")
            }
        }
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        // Testing
        print("Signed-up User:", realm.objects(User))
    }

    @IBAction func logInButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("logInSegue", sender: self)
    }
}
