
import UIKit

class SignUpViewController: UIViewController {

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
    
    @IBAction func registerButtonTapped(sender: AnyObject) {
        let userName = usernameTextField.text
        let userPassword = userpasswordTextField.text
        let user : [String:String] = ["username": userName!, "password": userPassword!]
        if(userName!.isEmpty){
            displayAlertMessage("All fields are required!")
        } else {
            SocketIOManager.sharedInstance.signUp(user)
        }
    }

    func displayAlertMessage(userMessage: String)
    {
        let myAlert = UIAlertController(title:"Alert", message: userMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
        
    }

}
