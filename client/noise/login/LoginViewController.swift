import UIKit
import RealmSwift
import Locksmith

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Override username and password events
        usernameTextField.delegate = self;
        passwordTextField.delegate = self;
        
        // Attach listeners
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handlePursuingKeyExchange),
            name: "stillPursuingKeyExchange",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(computeBob),
            name: "computeBob",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleCompletedKeyExchange),
            name: "KeyExchangeComplete",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(handleBobComplete),
            name: "bobComplete",
            object: nil)

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
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
            
            // Attach listeners
            NSNotificationCenter.defaultCenter().addObserver(
                self,
                selector: #selector(handleSignInNotification),
                name: "signin",
                object: nil)

            // Log in
            let userName = usernameTextField.text
            let userPassword = passwordTextField.text
            let user: [String: String] = [
                "username": userName!,
                "password": userPassword!
            ]

            SocketIOManager.sharedInstance.signIn(user)
        }
        
        return true
    }
    
    @objc func handleSignInNotification(notification: NSNotification) -> Void {
        
        if let signInObj = notification.userInfo {
            
            let userObj = signInObj["user"]
            
            // insert user data in realm
            let user = User()
            user.firstname = userObj!["firstname"] as! String
            user.lastname = userObj!["lastname"] as! String
            user.username = userObj!["username"] as! String
            user.userID = Int(userObj!["userID"] as! String)!
            user.ID = 0
            
            try! realm.write {
                realm.add(user, update:true)
            }
            var dhxObj : [String:AnyObject] = [:]
            dhxObj["userID"] = user.userID
            dhxObj["username"] = user.username
            //what else?!
            
            SocketIOManager.sharedInstance.checkForPendingKeyExchange(dhxObj)
            performSegueWithIdentifier("loginToFriendsListSegue", sender: self)
            
        } else {
            let alert:UIAlertController = UIAlertController(title: "Ooftah!", message: "username or password is incorrect", preferredStyle: UIAlertControllerStyle.Alert)
            let action:UIAlertAction = UIAlertAction(title: "okee", style: UIAlertActionStyle.Default) { (a: UIAlertAction) -> Void in
                print("okee button selected")
            }
            alert.addAction(action)
            self.presentViewController(alert, animated:true) { () -> Void in
                print("alert presented for unsuccessful login")
            }
        }
        
        // Remove listener
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func handlePursuingKeyExchange(notification:NSNotification) -> Void {
        let userInfo = notification.userInfo
        print("segue user info from login \(userInfo)")
        //self.performSegueWithIdentifier("friendsListToWaitSegue", sender: self)
    }
    
    @objc func computeBob(notification:NSNotification) -> Void {
        let dhxInfo = notification.userInfo
        print("dhx info inside of compute bob [LOGINVCONTROLLER] is \(dhxInfo!)")
        
        let Bob = 666.bobify(dhxInfo!["userID"]!, friendID: dhxInfo!["friendID"]!, E_Alice: dhxInfo!["eAlice"]!, p: dhxInfo!["pAlice"]!, g: dhxInfo!["gAlice"]!)
        
        SocketIOManager.sharedInstance.commencePart2KeyExchange(Bob)
    }
    
    @objc func handleCompletedKeyExchange(notification:NSNotification) -> Void {
        print("in handle complete")
         let dhxInfo = notification.userInfo
         let eBob_computational = UInt32(dhxInfo!["eBob"] as! String)
         let p_computational = UInt32(dhxInfo!["pAlice"] as! String)
         var Alice :[String:AnyObject] = [:]
         let aliceSecret = UInt32(Locksmith.loadDataForUserAccount("Alice_noise1")!["a_Alice"] as! String)
         print(aliceSecret)
        
         Alice["E"] = dhxInfo!["eAlice"]
         Alice["sharedSecret"] = String(666.computeSecret(eBob_computational!, mySecret: aliceSecret!, p: p_computational!))
         666.aliceKeyChainPt2(Alice)

        //instantiate Realm Chat
        self.performSegueWithIdentifier("loginToFriendsListSegue", sender: self)
        
    }
    
    @objc func handleBobComplete (notification:NSNotification) -> Void {
       print("hit BobComplete function")
        //instantiate Realm Chat
        self.performSegueWithIdentifier("loginToFriendsListSegue", sender: self)
    }
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("signUpSegue", sender: self)
    }
    
}
